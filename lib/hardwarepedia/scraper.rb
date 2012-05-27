
require 'net/http'
require 'enumerator'

module Hardwarepedia
  class Scraper
    LOG_FILENAME = Rails.root.join('log/scraper.log')
    # This is the max we can go before Postgres barfs
    # TODO: Raise max_connections in postgresql.conf??
    NUM_THREADS = 10  #20

    class Error < StandardError; end

    attr_reader :data, :doc, :total_num_pages

    def initialize
      # @manufacturers_by_name = Manufacturer.all.to_a.index_by(&:name)
      # @categories_by_name = Category.all.to_a.index_by(&:name)
      @data = {}
    end

    def config
      @config ||= Configuration.build(self)
    end

    def logger
      @logger ||= Logging.logger[self].tap do |logger|
        file_appender = Logging.appenders.file(LOG_FILENAME)
        stdout_appender = Logging.appenders.stdout
        logger.add_appenders(file_appender, stdout_appender)
        logger.level = :info
      end
    end

    def docs
      @docs ||= []
    end

    def doc
      docs.last
    end

    def scrape_products
      config.each_category_page do |category_page|
        product_urls = _get_category_product_urls(category_page)
        _scrape_product_urls(category_page.product_page, product_urls)
      end
    end

    # scrape_product(product_page, product_url)
    # scrape_product(retailer_name, product_page, product_url)
    #
    def scrape_product(*args)
      if args.length == 3
        retailer_name, category_name, product_url = args
        product_page = config.find_product(retailer_name, category_name)
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

      visiting(product_page, product_url, 'product') do
        pairs = doc.xpath('.//div[@id="Specs"]//dl/*').map {|node| node.text.sub(/:$/, "").strip }
        specs = Hash[*pairs]
        model_name = specs.delete("Model")
        manufacturer_name = specs.delete("Brand")
        if manufacturer_name.blank?
          # Have to do some more sleuthing...
          manufacturer_name = doc.xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()-1]/a/text()').first.text
        end
        full_name = [manufacturer_name, model_name].join(" ")

        # Save the product as soon as possible so that if other threads are
        # processing this same product for some reason, they can see that the
        # product already exists
        if product = Product.where(:full_name => full_name).first
          logger.info "(Found product '#{full_name}', updating)"
          product.state = 0
          product.save!
        else
          logger.info "Creating product '#{full_name}'"
          product = Product.create!(
            :category => @category,
            :name => model_name,
            :full_name => full_name
          )
        end
        product.content_urls << product_url
        product.specs = specs

        if manufacturer = Manufacturer.where(:name => manufacturer_name).first
          logger.info "(Reading manufacturer '#{manufacturer_name}' from cache)"
        else
          logger.info "Creating manufacturer '#{manufacturer_name}'"
          manufacturer = Manufacturer.create!(:name => manufacturer_name)
        end
        product.manufacturer = manufacturer

        chipset_manufacturer_name = specs.delete("Chipset Manufacturer")
        chipset_model_name = specs.delete("GPU").sub(%r{\s*\(.+?\)$}, "")
        if chipset_manufacturer = Manufacturer.where(:name => chipset_manufacturer_name).first
          logger.info "(Reading chipset manufacturer '#{chipset_manufacturer_name}' from cache)"
        else
          logger.info "Creating chipset manufacturer '#{chipset_manufacturer_name}'"
          chipset_manufacturer = Manufacturer.create!(:name => chipset_manufacturer_name)
        end
        chipset_full_name = "#{chipset_manufacturer_name} #{chipset_model_name}"
        if chipset = chipset_manufacturer.products.where(:name => chipset_model_name).first
          logger.info "(Found chipset product '#{chipset_full_name}')"
        else
          logger.info "Creating chipset product '#{chipset_full_name}'"
          chipset = Chipset.create!(
            :manufacturer => chipset_manufacturer,
            :category => @category,
            :name => chipset_model_name
          )
          # Eventually we will want to copy some of the attributes from this implementation product...
        end
        product.chipset = chipset

        product.images = []
        thumb_links = doc.xpath('.//ul[contains(@class, "navThumbs")]//a')
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
              product.images.create!(:url => url, :caption => caption)
            end
          end
        end

        _scrape_product_details(product, product_url)

        logger.info "Saving product record for '#{product.full_name}'"
        product.state = 1

        # Double check that the product doesn't already exist in the event that
        # it has already been processed in another thread
        if existing_product = Product.where(:full_name => product.full_name, :state => 1).first
          existing_product.update_attributes!(product.attributes)
        else
          product.save!
        end
      end
    rescue Error => e
      logger.error e
    end

  private
    def _get_category_product_urls(category_page)
      cache_key = Hardwarepedia::Util.cache_key(
        'retailer_category_product_urls',
        category_page.retailer_name,
        category_page.category_name,
      )
      logger.info "Retailer: #{category_page.retailer_name}"
      logger.info "Category name: #{category_page.category_name}"
      logger.info "-------------------"
      @category = fetch_category(category_page.category_name)

      Rails.cache.fetch(cache_key, :expires_in => 1.day) {
        # Visit the first page to get the total number of pages, then use the
        # pagination links on that page to go through the rest of the pages
        # and get a list of product urls
        all_product_urls = []
        visiting(category_page, category_page.page_url(1), 'page') do
          all_product_urls += category_page.product_urls
          # @total_num_pages = category_page.total_num_pages
          _collect_remaining_product_urls!(category_page, all_product_urls)
        end

        # Now go through all the product urls and scrape each product
        all_product_urls.sort.uniq
      }
    end

    def _collect_remaining_product_urls!(category_page, all_product_urls)
      use_threads = true #false

      each_url = proc do |page_url|
        visiting(category_page, page_url, 'page') do
          all_product_urls += category_page.product_urls
        end
      end
      each_urls = proc do |page_urls|
        page_urls.each do |page_url|
          each_url.call(page_url)
        end
      end

      if use_threads
        threads = []
        old_each_url = each_url
        each_url = proc do |page_url|
          threads << Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              old_each_url.call(page_url)
            end
          end
        end
        old_each_urls = each_urls
        each_urls = proc do |all_page_urls|
          all_page_urls.each_slice(NUM_THREADS) do |page_urls|
            threads.clear
            old_each_urls.call(page_urls)
            t = Time.now
            threads.each {|t| t.join }
            elapsed_time = Time.now - t
            logger.info("Finished #{NUM_THREADS} threads in %f seconds (%.1f t/s)" % [elapsed_time, (NUM_THREADS.to_f / elapsed_time)])
          end
        end
      end

      remaining_page_urls = category_page.page_urls(2)
      each_urls.call(remaining_page_urls)
    end

    def _scrape_product_urls(product_page, all_product_urls)
      use_threads = true #false

      each_url = proc do |product_url|
        scrape_product(product_page, product_url)
      end
      each_urls = proc do |urls|
        urls.each do |url|
          each_url.call(url)
        end
      end

      if use_threads
        threads = []
        old_each_url = each_url
        each_url = proc do |url|
          threads << Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              old_each_url.call(url)
            end
          end
        end
        old_each_urls = each_urls
        each_urls = proc do |all_urls|
          all_urls.each_slice(NUM_THREADS).each do |urls|
            threads.clear
            old_each_urls.call(urls)
            t = Time.now
            threads.each {|t| t.join }
            elapsed_time = Time.now - t
            logger.info("Finished #{NUM_THREADS} threads in %f seconds (%.1f t/s)" % [elapsed_time, (NUM_THREADS.to_f / elapsed_time)])
          end
        end
      end

      each_urls.call(all_product_urls)
    end

    def fetch(url)
      uri = URI.parse(url)
      i = 1
      num_seconds = 1
      content = nil
      begin
        full_path = uri.path + (uri.query ? "?#{uri.query}" : "")
        logger.info "Fetching #{url}..." if i == 0
        resp = Net::HTTP.start(uri.host, uri.port) do |http|
          http.read_timeout = 30
          http.get(full_path)
        end
        case resp
        when Net::HTTPSuccess, Net::HTTPRedirection
          content = resp.body
        else
          raise Error, "Error fetching #{url}: got status code #{resp.code} (#{resp.message})"
        end
      rescue Timeout::Error, SocketError, Error => e
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
    # XXX: This actually no longer happens, but the block is still okay, I guess
    def visiting(page, url, type, &block)
      body = fetch(url)
      doc = Nokogiri.parse(body)
      node_set = doc.xpath(page.content_xpath)
      unless node_set
        raise Error, "Couldn't find content at <#{page.content_xpath}>!"
      end

      # Remove script and style tags
      node_set.xpath('.//script | .//style').unlink

      page.preprocess!(node_set) if page.respond_to?(:preprocess!)
      docs << node_set
      content_html = node_set.to_html
      content_md5 = Url.digest_content(content_html)
      if u = Url.find(url)
        # logger.info "Url: #{url}"
        # require 'diffy'
        # diff = Diffy::Diff.new(u.content_html, content_html)
        # puts diff.to_s(:color)
        # exit

        # We've scraped this URL before.
        if type == 'product' && u.content_md5 == content_md5
          # The content of this page hasn't changed since we last scraped it,
          # so no need to scrape it again
          logger.info "(Already scraped <#{url}>, and it hasn't changed since last scrape)"
        else
          # The content of the page *has* changed since we last scraped it,
          # so just update the signature of the content
          if type == 'product'
            logger.info "Already scraped <#{url}>, but it's changed since last scrape, so updating md5"
          else
            logger.info "Scraping <#{url}> regardless of content since it's a collection page"
          end
          u.state = 0
          u.content_md5 = content_md5
          u.save
          yield
          u.state = 1
          u.save
        end
      else
        # We haven't scraped this URL yet, so add it to the database.
        logger.info "Haven't scraped <#{url}> yet, content md5 is #{content_md5}"
        u = Url.create(
          :url => url,
          :content_html => content_html,
          :content => content_md5,
          :kind => type
        )
        yield
        u.state = 1
        u.save
      end
      docs.pop
    rescue Error => e
      logger.error e
    end

    def fetch_category(category_name)
      if category = Category.where(:name => category_name).first
        logger.info "(Reading category '#{category_name}' from cache)"
      else
        logger.info "Creating category '#{category_name}'"
        category = Category.create!(:name => category_name)
      end
      category
    end

    def _scrape_product_details(product, product_url)
      # Are you serious
      sku = doc.at_xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()]').text.sub(/^Item[ ]*#:[ ]*/, "").to_ascii.strip
      javascript = fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
      json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
      hash = JSON.parse(json)
      product.prices.create!(:url => product_url, :amount => hash["finalPrice"])

      # XXX: Should this be itemRating??
      rating_node = doc.at_xpath('.//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
      # Some products will naturally not have any reviews yet, so there is no rating.
      if rating_node && rating_raw_value = rating_node.text.presence
        num_reviews = rating_node.next.text.scan(/\d+/).first
        product.ratings.create!(:url => product_url, :raw_value => rating_raw_value, :num_reviews => num_reviews)
      end
    end
  end
end
