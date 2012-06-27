
module Hardwarepedia
  class Scraper

    class ProductPageScraper
      attr_reader :scraper, :category, :product_page, :product_url

      def initialize(scraper, category, product_page, product_url)
        @scraper = scraper
        @category = category
        @product_page = product_page
        @product_url = product_url

        @retailer = product_page.retailer
      end

      def call
        @scraper.visiting(product_page, product_url, 'product') do |doc|
          @doc = doc

          pairs = doc.xpath('.//div[@id="Specs"]//dl/*').map {|node| node.text.sub(/:$/, "").strip }
          @specs = Hash[*pairs]

          manufacturer_name = _scrape_manufacturer_name

          # Save the product as soon as possible so that if other threads are
          # processing this same product for some reason, they can see that the
          # product already exists
          @model_name = _scrape_model_name
          @full_name = [manufacturer_name, @model_name].join(" ")
          @product = _find_or_create_product

          @product.content_urls << product_url
          @product.specs = @specs

          @product.manufacturer = @manufacturer =
            _find_or_create_manufacturer(manufacturer_name)

          chipset_manufacturer_name = _scrape_chipset_manufacturer_name
          chipset_model_name = _scrape_chipset_model_name
          @chipset_manufacturer = _find_or_create_manufacturer(
            chipset_manufacturer_name, :chipset => true
          )
          @product.chipset = @chipset =
            _find_or_create_chipset_product(chipset_model_name)

          _scrape_images
          _scrape_prices
          _scrape_ratings

          logger.info "Saving product record for '#{@product.full_name}'"
          @product.state = 1

          # Double check that the product doesn't already exist in the event that
          # it has already been processed in another thread
          # if existing_product = Product.find(:full_name => product.full_name, :state => 1).first
          #   existing_product.update_attributes!(product.attributes)
          # else
            @product.save!
          # end
        end
      rescue Error => e
        logger.error e
      end

      def _scrape_model_name
        @specs.delete("Model")
      end

      def _scrape_manufacturer_name
        manufacturer_name = @specs.delete("Brand")
        if manufacturer_name.blank?
          # Have to do some more sleuthing...
          manufacturer_name = doc.xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()-1]/a/text()').first.text
        end
        manufacturer_name
      end

      def _find_or_create_product
        Product.with_or_create({:full_name => @full_name},
          :category => @category,
          :name => @model_name,
          :full_name => @full_name,
          :state => 0
        )
      end

      def _find_or_create_manufacturer(manufacturer_name)
        Manufacturer.with_or_create(:name => manufacturer_name)
      end

      def _scrape_chipset_manufacturer_name
        @specs.delete("Chipset Manufacturer")
      end

      def _scrape_chipset_model_name
        @specs.delete("GPU").sub(%r{\s*\(.+?\)$}, "")
      end

      def _find_or_create_chipset_product(chipset_model_name)
        Chipset.with_or_create({:full_name => chipset_full_name},
          :manufacturer => @chipset_manufacturer,
          :category => @category,
          :name => chipset_model_name,
          :state => 0
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
              # TODO: Does this really have two d's?
              sub(/^Biz\.Product\.DetailPage\.swapProductImageWithLoadding\('/, "").
              sub(/',this\.href,''\);$/, "")
            caption = thumb_link["title"]
            # We have the url of the thumbnail but we need a url of the entire image
            url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
            image = Image.with_or_create({:url => url},
              :reviewable => @product,
              :reviewable_url => @product_url,
              :caption => caption
            )
            @product.images.add(image)
          end
        end
      end

      def _scrape_prices
        # Are you serious...
        sku = @doc.at_xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()]').
          text.sub(/^Item[ ]*#:[ ]*/, "").to_ascii.strip
        javascript = fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
        json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
        hash = JSON.parse(json)
        amount = (hash['finalPrice'].to_f * 100).to_i
        price = Price.with_or_create({:reviewable_url => @product_url},
          :product => @product,
          :amount => amount
        )
        @product.prices.add(price)
      end

      def _scrape_ratings
        ratings = []
        # XXX: Should this be itemRating??
        rating_node = @doc.at_xpath('.//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
        # Some products will naturally not have any reviews yet, so there is no rating.
        if rating_node && rating_raw_value = rating_node.text.presence
          num_reviews = rating_node.next.text.scan(/\d+/).first.to_i
          rating = Rating.with_or_create({:reviewable_url => product_url},
            :product => @product,
            :raw_value => rating_raw_value,
            :num_reviews => num_reviews
          )
          @product.ratings.add(rating)
        end
      end
    end

  end
end
