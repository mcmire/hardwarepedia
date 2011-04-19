module Hardwarepedia
  class Scraper
    attr_reader :data, :doc
    
    def initialize
      @manufacturers_by_name = Manufacturer.all.to_a.to_hash_by(&:name)
      @categories_by_name = Category.all.to_a.to_hash_by(&:name)
      @data = {}
      Pages.scraper = self
    end

    def docs
      @docs ||= []
    end

    def doc
      docs.last
    end

    def scrape_products
      Pages.each_category_page do |category_page|
        puts "Retailer: #{category_page.retailer_name}"
        puts "Category name: #{category_page.category_name}"
        puts "-------------------"
        @category = fetch_category(category_page.category_name)
        continue = true
        while continue
          visiting(category_page, category_page.url) do
            category_page.product_urls.each do |url|
              scrape_product(category_page.product_page, url)
            end
            continue = category_page.next_url?
          end
        end
      end
    end
  
    def scrape_product(*args)
      if args.length == 3
        retailer_name, category_name, product_url = args
        product_page = Pages.find_product(retailer_name, category_name)
        unless product_page
          raise "No product page for #{retailer_name} / #{category_name} ?!"
        end
        @category = fetch_category(category_name)
        
        puts "Retailer: #{retailer_name}"
        puts "Category name: #{category_name}"
        puts "-------------------"
      else
        product_page, product_url = args
        retailer_name = product_page.retailer_name
        category_name = product_page.category_name
      end
      
      visiting(product_page, product_url) do
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
        product.category = @category
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
          chipset = Product.create!(category: @category, manufacturer: chipset_manufacturer, name: chipset_model_name, is_chipset: true)
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
      
        _scrape_product_details(product, product_url)

        puts "Saving product record for '#{product.full_name}'"
        product.save!
      end
    end

  private
    def fetch(url)
      uri = URI.parse(url)
      i = 1
      num_seconds = 1
      content = nil
      begin
        full_path = uri.path + (uri.query ? "?#{uri.query}" : "")
        if i > 1
          puts "Hmm, that didn't seem to work. Trying again..."
        else
          puts "Fetching #{url}..."
        end
        session = Patron::Session.new
        session.timeout = 20
        session.base_url = "#{uri.scheme}://#{uri.host}"
        resp = session.get(full_path)
        if resp.status != 200
          raise "Error fetching #{url}: status code #{resp.status} (#{resp.status_line}; #{resp.url})"
        end
        content = resp.body
      rescue Patron::Error => e
        if i == 5
          puts "#{e.class}: #{e.message}"
          exit 1
        else
          i += 1
          sleep(num_seconds)
          num_seconds += 1
          retry
        end
      end
      content
    end
  
    # This requires a block b/c we don't want the url to be saved until after
    # we've scraped the url
    def visiting(page, url, &block)
      body = fetch(url)
      doc = Nokogiri.parse(body)
      docs.push doc
      node = doc.at_xpath(page.content_xpath) or raise "Couldn't find content at <#{page.content_xpath}>!"
      content_html = node.to_html
      content_md5 = Url.md5(content_html)
      if u = Url.where(url: url).first
        # We've scraped this URL before.
        if u.content_md5 == content_md5
          # The content of this page hasn't changed since we last scraped it,
          # so no need to scrape it again
          puts "(Already scraped <#{url}>, and it hasn't changed since last scrape)"
        else
          # The content of the page *has* changed since we last scraped it,
          # so just update the signature of the content
          puts "Already scraped <#{url}>, but it's changed since last scrape, so updating md5"
          yield
          u.content_md5 = content_md5
          u.save!
        end
      else
        puts "Haven't scraped <#{url}> yet, content md5 is #{content_md5}"
        yield
        # We haven't scraped this URL yet, so add it to the database.
        Url.create!(url: url, body: body, content_md5: content_md5)
      end
    ensure
      docs.pop
    end
    
    def fetch_category(category_name)
      if category = @categories_by_name[category_name]
        puts "(Reading category '#{category_name}' from cache)"
      else
        puts "Creating category '#{category_name}'"
        category = @categories_by_name[category_name] = Category.create!(name: category_name)
      end
      category
    end
    
    def _scrape_product_details(product, product_url)
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