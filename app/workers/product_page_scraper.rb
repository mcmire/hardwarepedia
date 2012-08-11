
class ProductPageScraper
  include Hardwarepedia::Sidekiq::Worker

  def perform(site_id, category_id, product_url)
    @site = Site[site_id]
    @category = Category[category_id]
    @product_url = product_url

    site_config = scraper.config.sites[@site.name]
    @product_page = site_config.nodes[@category.name].nodes[:product]

    _scrape_page
  end

  def _scrape_page
    scraper.visiting(@product_page, @product_url) do |url, doc|
      @url = url
      @doc = doc

      pairs = @doc.xpath('.//div[@id="Specs"]//dl/*').map {|node| node.text.sub(/:$/, "").strip }
      @specs = Hash[*pairs]
      @orig_specs = @specs.dup

      @manufacturer_name = _scrape_manufacturer_name
      @model_name = _scrape_model_name
      @full_name = [@manufacturer_name, @model_name].join(" ")
      @product = _find_or_build_product
      if @product.nil?
        # nil means the product is currently being processed by another
        # thread. let's let it do its thing.
        return
      end
      # otherwise, go ahead and save it so if another thread comes along and
      # looks for this product it will find it
      @product.save

      @product.content_urls << @url.url
      @product.specs = @specs

      @manufacturer = _find_or_create_manufacturer(@manufacturer_name)
      @product.manufacturer_id = @manufacturer.id

      @chipset_manufacturer_name = _scrape_chipset_manufacturer_name
      @chipset_model_name = _scrape_chipset_model_name
      @chipset_manufacturer =
        _find_or_create_manufacturer(@chipset_manufacturer_name)
      @chipset = _find_or_create_chipset_product
      @product.chipset_id = @chipset.id

      # product has to be saved before we can add associations
      @product.state = 0
      @product.save

      _scrape_images
      _scrape_prices
      _scrape_ratings

      @product.state = 1
      @product.save

      @url.resource = @product
    end
  end

  def _scrape_model_name
    model_name = @specs.delete("Model").to_s.strip
    unless model_name
      raise "Couldn't find model name!\nSpecs are: #{@orig_specs.pretty_inspect}"
    end
    model_name
  end

  def _scrape_manufacturer_name
    manufacturer_name = @specs.delete("Brand").to_s.strip
    if manufacturer_name.blank?
      # Have to do some more sleuthing...
      if node = @doc.xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()-1]/a/text()').first
        manufacturer_name = node.text.strip
      end
    end
    if manufacturer_name.blank?
      raise "Couldn't find manufacturer!"
    end
    manufacturer_name
  end

  def _find_or_build_product
    logger.debug "Finding or building product #{@full_name.inspect}"
    conds = {:type => 'product', :full_name => @full_name}
    attrs = {
      :category_id => @category.id,
      :name => @model_name,
      :state => 0
    }
    if rev = Reviewable.first(conds)
      if rev.complete?
        # reset
        rev.set(attrs)
        return rev
      else
        return nil
      end
    else
      return Reviewable.new conds.merge(attrs)
    end
  end

  def _find_or_create_manufacturer(name)
    Manufacturer.first_or_create_by(:name => name)
  end

  def _scrape_chipset_manufacturer_name
    chipset_manufacturer_name = @specs.delete("Chipset Manufacturer").to_s.strip
    if chipset_manufacturer_name.blank?
      raise "No chipset manufacturer name found!\nSpecs are: #{@orig_specs.pretty_inspect}"
    end
    chipset_manufacturer_name
  end

  def _scrape_chipset_model_name
    chipset_model_name = @specs.delete("GPU").to_s.strip
    if chipset_model_name.blank?
      raise "No chipset model name found!\nSpecs are: #{@orig_specs.pretty_inspect}"
    end
    chipset_model_name.sub!(%r{\s*\(.+?\)$}, "")
    chipset_model_name
  end

  def _find_or_create_chipset_product
    chipset_full_name = "#{@chipset_manufacturer_name} #{@chipset_model_name}"
    logger.debug "Finding or creating chipset #{chipset_full_name.inspect}"
    # do not reset the state of the chipset object here as we may process
    # two products in a row that point to the same chipset - we will set the
    # state of the chipset if/when we actually come to it in processing
    Reviewable.first_or_create_by(
      {:type => 'chipset',
       :full_name => chipset_full_name},
      {:manufacturer_id => @chipset_manufacturer.id,
       :category_id => @category.id,
       :name => @chipset_model_name}
       # Eventually we will want to copy some of the attributes from this
       # implementation product...
    )
  end

  def _scrape_images
    thumb_links = @doc.xpath('.//ul[contains(@class, "navThumbs")]//a')
    for thumb_link in thumb_links
      # this will give me back xml - i can read the fset element and get dx and dy to get the image dimensions
      "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=fvctx,xml,UTF-8,4&scl=1"
      # this will give me a tile of the image where XXX... is just a random string of chars [0-9A-Za-z_-]
      # and rect is two coords - top left and bottom right
      "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=tile&id=XXXXXXXXXXXXXXXXXXXXXX&rect=0,0,1000,1000"

      # Some products have more than four images. If that's true then another
      # thumbnail image will appear on the page that's an ellipsis icon.
      # This image won't have an onmouseover, so we will want to ignore it.
      if thumb_link["onmouseover"]
        thumb_url = thumb_link["onmouseover"].
          # Yes, this really has two d's...
          sub(/^Biz\.Product\.DetailPage\.swapProductImageWithLoadding2011\('/, "").
          sub(/',this\.href,''\);$/, "")
        thumb_url.strip!
        caption = thumb_link["title"].
          sub(/\(Image \d+,New Window\)$/, "")
        caption.strip!
        # We have the url of the thumbnail but we need a url of the entire image
        url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
        image = Image.first_or_create_by(
          {:url => url},
          {:reviewable_id => @product.id,
           :reviewable_url => @url.url,
           :caption => caption}
        )
        # remember in Sequel this does not actually do any saving, it just
        # adds it to an internal array
        @product.images << image
      end
    end
  end

  def _scrape_prices
    # Are you serious...
    sku = @doc.at_xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()]').
      text.sub(/^Item[ ]*#:[ ]*/, "").to_ascii.strip
    javascript = scraper.fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
    json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
    hash = MultiJson.load(json)
    amount = (hash['finalPrice'].to_f * 100).to_i
    price = Price.first_or_create_by(
      {:reviewable_url => @url.url},
      {:reviewable_id => @product.id,
       :amount => amount}
    )
    # remember in Sequel this does not actually do any saving, it just
    # adds it to an internal array
    @product.prices << price
  end

  def _scrape_ratings
    ratings = []
    # If the product has no ratings yet then this node will not be available
    if rating_box_node = @doc.at_xpath('.//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]')
      rating_node = rating_box_node.at_xpath('./span[@itemprop="ratingValue"]')
      rating_raw_value = "#{rating_node['content']}/5"
      num_reviews_node = rating_box_node.at_xpath('./span[@itemprop="reviewCount"]')
      num_reviews = num_reviews_node.text.to_i
      rating = Rating.first_or_create_by(
        {:reviewable_url => @url.url},
        {:reviewable_id => @product.id,
         :raw_value => rating_raw_value,
         :num_reviews => num_reviews}
      )
      # remember in Sequel this does not actually do any saving, it just
      # adds it to an internal array
      @product.ratings << rating
    end
  end
end

