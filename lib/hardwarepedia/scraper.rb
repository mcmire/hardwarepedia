
require 'net/http'
require 'enumerator'

module Hardwarepedia
  class Scraper
    NUM_THREADS = 3

    class Error < StandardError; end

    attr_reader :data, :doc, :total_num_pages

    def initialize
      @manufacturers_by_name = Manufacturer.all.to_a.index_by(&:name)
      @categories_by_name = Category.all.to_a.index_by(&:name)
      @data = {}
    end

    def configuration
      @config ||= Configuration.build(self)
    end

    def logger
      Configuration.logger
    end

    def docs
      @docs ||= []
    end

    def doc
      docs.last
    end

    def scrape_products
      configuration.each_category_page do |category_page|
        logger.info "Retailer: #{category_page.retailer_name}"
        logger.info "Category name: #{category_page.category_name}"
        logger.info "-------------------"
        @category = fetch_category(category_page.category_name)

        all_product_urls = []
        # Visit the first page to get the total number of pages
        visiting(category_page, category_page.page_url(1)) do
          all_product_urls += category_page.product_urls
          @total_num_pages = doc.at_xpath('//span[@id="totalPage"]').text.to_i

          threads = []
          category_page.page_urls(2).each_slice(NUM_THREADS) do |page_urls|
            threads << Thread.new do
              page_urls.each do |page_url|
                visiting(category_page, page_url) do
                  all_product_urls += category_page.product_urls
                end
              end
            end
          end
          threads.each {|t| t.join }
          all_product_urls.sort!
          all_product_urls.uniq!
          #all_product_urls = [ all_product_urls[0] ]

          threads = []
          all_product_urls.each_slice(NUM_THREADS).each do |product_urls|
            threads << Thread.new do
              product_urls.each do |product_url|
                scrape_product(category_page.product_page, product_url)
              end
            end
          end
          threads.each {|t| t.join }
        end
      end
    end

    def scrape_product(*args)
      if args.length == 3
        retailer_name, category_name, product_url = args
        product_page = configuration.find_product(retailer_name, category_name)
        unless product_page
          raise Error, "No product page for #{retailer_name} / #{category_name} ?!"
        end
        @category = fetch_category(category_name)

        logger.info "Retailer: #{retailer_name}"
        logger.info "Category name: #{category_name}"
        logger.info "-------------------"
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

        if product = ::Product.where(:full_name => full_name).first
          logger.info "(Found product '#{manufacturer_name} #{model_name}')"
        else
          logger.info "Creating product '#{manufacturer_name} #{model_name}'"
          product = ::Product.new(:full_name => full_name)
        end
        product.category = @category
        if product.manufacturer = @manufacturers_by_name[manufacturer_name]
          logger.info "(Reading manufacturer '#{manufacturer_name}' from cache)"
        else
          logger.info "Creating manufacturer '#{manufacturer_name}'"
          product.manufacturer = @manufacturers_by_name[manufacturer_name] = Manufacturer.create!(:name => manufacturer_name)
        end
        product.name = model_name
        product.content_urls << product_url
        product.specs = specs

        chipset_manufacturer_name = specs.delete("Chipset Manufacturer")
        chipset_model_name = specs.delete("GPU").sub(%r{\s*\(.+?\)$}, "")
        if chipset_manufacturer = @manufacturers_by_name[chipset_manufacturer_name]
          logger.info "(Reading chipset manufacturer '#{chipset_manufacturer_name}' from cache)"
        else
          logger.info "Creating chipset manufacturer '#{chipset_manufacturer_name}'"
          chipset_manufacturer = @manufacturers_by_name[chipset_manufacturer_name] = Manufacturer.create!(:name => chipset_manufacturer_name)
        end
        chipset_full_name = "#{chipset_manufacturer_name} #{chipset_model_name}"
        if chipset = ::Product.where(:manufacturer_id => chipset_manufacturer.id, :name => chipset_model_name).first
          logger.info "(Found chipset product '#{chipset_full_name}')"
        else
          logger.info "Creating chipset product '#{chipset_full_name}'"
          chipset = ::Product.create!(:category => @category, :manufacturer => chipset_manufacturer, :name => chipset_model_name, :is_chipset => true)
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
            unless product.images.where(:url => url).exists?
              product.images << Image.new(:url => url, :caption => caption)
            end
          end
        end

        _scrape_product_details(product, product_url)

        logger.info "Saving product record for '#{product.full_name}'"
        product.save!
      end
    rescue Error => e
      logger.error e
    end

  private
    def fetch(url)
      uri = URI.parse(url)
      i = 1
      num_seconds = 1
      content = nil
      begin
        full_path = uri.path + (uri.query ? "?#{uri.query}" : "")
        logger.info "Fetching #{url}..." if i == 0
        resp = Net::HTTP.start(uri.host, uri.port) do |http|
          http.read_timeout = 20
          http.get(full_path)
        end
        case resp
        when Net::HTTPSuccess, Net::HTTPRedirection
          content = resp.body
        else
          raise Error, "Error fetching #{url}: got status code #{resp.code} (#{resp.message})"
        end
      rescue SocketError, Error => e
        if i == 5
          raise Error, "#{e.class} fetching #{url}: #{e.message}"
        else
          logger.error "Hmm, that didn't seem to work. Trying again..."
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
      node = doc.at_xpath(page.content_xpath) or raise Error, "Couldn't find content at <#{page.content_xpath}>!"
      content_html = node.to_html
      content_md5 = Url.md5(content_html)
      if u = Url.where(:url => url).first
        # We've scraped this URL before.
        if u.content_md5 == content_md5
          # The content of this page hasn't changed since we last scraped it,
          # so no need to scrape it again
          logger.info "(Already scraped <#{url}>, and it hasn't changed since last scrape)"
        else
          # The content of the page *has* changed since we last scraped it,
          # so just update the signature of the content
          logger.info "Already scraped <#{url}>, but it's changed since last scrape, so updating md5"
          yield
          u.content_md5 = content_md5
          u.save!
        end
      else
        logger.info "Haven't scraped <#{url}> yet, content md5 is #{content_md5}"
        yield
        # We haven't scraped this URL yet, so add it to the database.
        Url.create!(:url => url, :body => body, :content_md5 => content_md5)
      end
      docs.pop
    rescue Error => e
      logger.error e
    end

    def fetch_category(category_name)
      if category = @categories_by_name[category_name]
        logger.info "(Reading category '#{category_name}' from cache)"
      else
        logger.info "Creating category '#{category_name}'"
        category = @categories_by_name[category_name] = Category.create!(:name => category_name)
      end
      category
    end

    def _scrape_product_details(product, product_url)
      # Are you serious
      sku = doc.at_xpath('//div[@id="bcaBreadcrumbTop"]//dd[last()]').text.sub(/^Item[ ]*#:[ ]*/, "").to_ascii.strip
      javascript = fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
      json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
      hash = JSON.parse(json)
      product.prices << Price.new(:url => product_url, :amount => hash["finalPrice"])

      # XXX: Should this be itemRating??
      rating_node = doc.at_xpath('//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
      # Some products will naturally not have any reviews yet, so there is no rating.
      if rating_node && rating_raw_value = rating_node.text.presence
        num_reviews = rating_node.next.text.scan(/\d+/).first
        product.ratings << Rating.new(:url => product_url, :raw_value => rating_raw_value, :num_reviews => num_reviews)
      end
    end
  end
end
