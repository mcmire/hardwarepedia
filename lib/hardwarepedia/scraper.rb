module Hardwarepedia
  class Scraper
    def initialize
      @manufacturers_by_name = Manufacturer.all.to_a.to_hash_by(&:name)
      @categories_by_name = Category.all.to_a.to_hash_by(&:name)
      @category_name = "Graphics Cards"
    end

    def scrape_products
      puts "## About to screenscrape #{@category_name}, hold on to your hats..."
      puts "----------"
    
      if category = @categories_by_name[@category_name]
        puts "(Reading category '#{@category_name}' from cache)"
      else
        puts "Creating category '#{@category_name}'"
        category = @categories_by_name[@category_name] = Category.create!(name: @category_name)
      end
    
      current_page = 1
      total_pages = nil
      until total_pages && current_page > total_pages
        doc = visit("http://www.newegg.com/Store/SubCategory.aspx?SubCategory=48&name=Desktop-Graphics-Video-Cards&Page=#{current_page}")
        total_pages ||= doc.at_xpath('//span[@id="totalPage"]').text.to_i
      
        links = doc.xpath("//span[contains(@class, 'itemDescription')]/parent::a")
        products = []
        links.each do |link|
          product_url = link["href"]
          scrape_product(product_url, category)
        end
        current_page += 1
        puts "----------"
      end
    end
  
    def scrape_product(product_url, category)
      doc = visit(product_url)

      values = doc.xpath('//div[@id="Specs"]//dl/dt | //div[@id="Specs"]//dl/dd').map {|node| node.text.sub(/:$/, "").strip }
      specs = Hash[*values]
      model_name = specs.delete("Model")
      manufacturer_name = specs.delete("Brand")
      if manufacturer_name.blank?
        # Have to do some more sleuthing...
        manufacturer_name = doc.xpath('//div[@id="bcaBreadcrumbTop"]//dd[last()-1]/a/text()').first.text
      end
      full_name = "#{manufacturer_name} #{model_name}"
  
      if product = Product.where(full_name: full_name).first
        puts "(Found product '#{manufacturer_name} #{model_name}')"
      else
        puts "Creating product '#{manufacturer_name} #{model_name}'"
        product = Product.new(full_name: full_name)
      end
      product.category = category
      if product.manufacturer = @manufacturers_by_name[manufacturer_name]
        puts "(Reading manufacturer '#{manufacturer_name}' from cache)"
      else
        puts "Creating manufacturer '#{manufacturer_name}'"
        product.manufacturer = @manufacturers_by_name[manufacturer_name] = Manufacturer.create!(name: manufacturer_name)
      end
      product.name = model_name
      product.content_urls << product_url
      product.specs = specs

      chipset_manufacturer_name = specs.delete("Chipset Manufacturer")
      chipset_model_name = specs.delete("GPU").sub(%r{\s*\(.+?\)$}, "")
      if chipset_manufacturer = @manufacturers_by_name[chipset_manufacturer_name]
        puts "(Reading chipset manufacturer '#{chipset_manufacturer_name}' from cache)"
      else
        puts "Creating chipset manufacturer '#{chipset_manufacturer_name}'"
        chipset_manufacturer = @manufacturers_by_name[chipset_manufacturer_name] = Manufacturer.create!(name: chipset_manufacturer_name)
      end
      chipset_full_name = "#{chipset_manufacturer_name} #{chipset_model_name}"
      if chipset = Product.where(manufacturer_id: chipset_manufacturer.id, name: chipset_model_name).first
        puts "(Found chipset product '#{chipset_full_name}')"
      else
        puts "Creating chipset product '#{chipset_full_name}'"
        chipset = Product.create!(category: category, manufacturer: chipset_manufacturer, name: chipset_model_name, is_chipset: true)
        # Eventually we will want to copy some of the attributes from this implementation product...
      end
      product.chipset = chipset

      product.images = []
      thumb_links = doc.xpath('//ul[contains(@class, "navThumbs")]//a')
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
            sub(/^Biz\.Product\.DetailPage\.swapProductImageWithLoadding\('/, "").
            sub(/',this\.href,''\);$/, "")
          caption = thumb_link["title"]
          # We have the url of the thumbnail but we need a url of the entire image
          url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
          unless product.images.where(url: url).exists?
            product.images << Image.new(url: url, caption: caption)
          end
        end
      end
      
      _scrape_product_details(product, product_url, doc)

      puts "Saving product record for '#{product.full_name}'"
      product.save!
    end

  private
    def fetch(url)
      if u = Url.where(url: url).first
        puts "(Reading #{url} from cache)"
        u.content
      else
        uri = URI.parse(url)
        i = 1
        begin
          full_path = uri.path + (uri.query ? "?#{uri.query}" : "")
          puts "Fetching #{url}..."
          session = Patron::Session.new
          session.timeout = 10
          session.base_url = "#{uri.scheme}://#{uri.host}"
          resp = session.get(full_path)
          if resp.status != 200
            raise "Error fetching #{url}: status code #{resp.status} (#{resp.status_line}; #{resp.url})"
          end
        rescue Patron::TimeoutError => e
          if i == 3
            raise e
          else
            i += 1
            retry
          end
        end
        Url.create!(url: url, content: resp.body)
        resp.body
      end
    end

    def visit(url)
      Nokogiri.parse(fetch(url))
    end
    
    def _scrape_product_details(product, product_url, doc)
      # Are you serious
      sku = doc.at_xpath('//div[@id="bcaBreadcrumbTop"]//dd[last()]').text.sub(/^Item[ ]*#:[ ]*/, "")[1..-1]
      javascript = fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
      json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
      hash = Yajl::Parser.parse(json)
      product.prices << Price.new(url: product_url, amount: hash["finalPrice"])

      rating_node = doc.at_xpath('//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
      # Some products will naturally not have any reviews yet, so there is no rating.
      if rating_node && rating_raw_value = rating_node.text.presence
        num_reviews = rating_node.next.text.scan(/\d+/).first
        product.ratings << Rating.new(url: product_url, raw_value: rating_raw_value, num_reviews: num_reviews)
      end
    end
  end
end