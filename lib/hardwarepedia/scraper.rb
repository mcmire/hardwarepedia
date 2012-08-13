
require 'net/http'
require 'enumerator'

module Hardwarepedia

  class Scraper
    LOG_FILENAME = Rails.root.join('log/scraper.log')
    # This is the max we can go before Postgres barfs
    # TODO: Raise max_connections in postgresql.conf??
    NUM_THREADS = 10  #20

    class Error < StandardError; end

    class FetchError < Error
      attr_reader :uri, :err

      def initialize(uri, err)
        @uri = uri
        @err = err
      end

      def url
        @uri.to_s
      end

      def message
        "#{@err.class} fetching #{url}: #{@err.message}"
      end
    end

    class HTTPError < Error
      attr_reader :uri, :resp

      def initialize(uri, resp)
        @uri = uri
        @resp = resp
      end

      def url
        @uri.to_s
      end

      def message
        "Error fetching #{url}: got status code #{@resp.code} (#{@resp.message})"
      end
    end

    attr_reader :config

    def initialize
      @config = Configuration.build(self)
      logger  # initialize
    end

    def logger
      @logger ||= Logging.logger['Hardwarepedia::Scraper'].tap do |logger|
        logger.additive = false
        logger.level = :debug
        # This is the same as in config/logging.rb
        pattern = '[%d] %-5l %50c TID-%S%s :: %m\n'
        date_pattern = '%Y-%m-%d %H:%M:%S.%6N'

        file_appender = Logging::Appenders::File.new('Scraper_file',
          :auto_flushing => true,
          :filename => LOG_FILENAME,
          :layout => Hardwarepedia::Scraper::LogPattern.new(
            :pattern => pattern,
            :date_pattern => date_pattern
          ),
          :level => :debug
        )
        stdout_appender = Logging::Appenders::IO.new('Scraper_stdout', $stdout,
          :auto_flushing => true,
          :layout => Hardwarepedia::Scraper::LogPattern.new(
            :pattern => pattern,
            :date_pattern => date_pattern,
            :color_scheme => 'bright'
          ),
          :level => :debug
        )

        logger.appenders = [
          file_appender,
          # stdout_appender
        ]
      end
    end

    # def scrape_products(site_name)
    #   site = _find_or_create_site(site_name)
    #   config.sites[site_name].nodes.each_key do |category_name|
    #     category = _find_or_create_category(category_name)
    #     Hardwarepedia.queue(CategoryPageScraper, site.id, category.id)
    #   end
    # end

    def scrape_category(site_name, category_name)
      site = _find_or_create_site(site_name)
      category = _find_or_create_category(category_name)
      Hardwarepedia.queue(CategoryScraper, site.id, category.id)
    end

    def scrape_product(site_name, category_name, product_url)
      site = _find_or_create_site(site_name)
      category = _find_or_create_category(category_name)
      Hardwarepedia.queue(ProductPageScraper, site.id, category.id, product_url)
    end

    def visiting(page_config, url, resource=nil)
      body = fetch(url)
      doc = Nokogiri.parse(body)
      node_set = doc.xpath(page_config.content_xpath)
      unless node_set
        raise Error, "Couldn't find content at <#{page_config.content_xpath}>!"
      end

      # Remove script and style tags
      node_set.xpath('.//script | .//style').unlink

      page_config.preprocess!(node_set) if page_config.respond_to?(:preprocess!)
      content_html = node_set.to_html
      ourl2 = Url.new(:url => url, :content_html => content_html)
      if ourl = Url.find_fresh(url)
        if resource
          ourl.resource = resource
          ourl.save
        end
        if Category === resource
          logger.debug "Already scraped <#{url}>, but going to process anyway since it's a category page"
          # ourl.state = 0
          # ourl.save
          yield ourl, doc
          # ourl.state = 1
          # ourl.save
        else
          logger.debug "Already scraped <#{url}>, and it hasn't changed since last scrape, proceeding"
        end
      else
        ourl = ourl2
        logger.debug "Haven't scraped <#{url}> yet, content md5 is #{ourl.content_digest}"
        if resource
          ourl.resource = resource
          ourl.save
        end
        # ourl.save
        yield ourl, doc
        # ourl.state = 1
        # ourl.save
      end
    rescue Error => e
      logger.error e
    end

    # You can use this method instead of #visiting if you just want to fetch a
    # URL (for instance we use this in ProductPageScraper)
    #
    def fetch(url)
      uri = URI.parse(url)
      i = 1
      num_seconds = 1
      content = nil
      begin
        full_path = uri.path + (uri.query ? "?#{uri.query}" : "")
        logger.debug "Fetching #{url}..." if i == 0
        resp = Net::HTTP.start(uri.host, uri.port) do |http|
          http.read_timeout = 30
          http.get(full_path)
        end
        case resp
        when Net::HTTPSuccess, Net::HTTPRedirection
          content = resp.body
        else
          raise HTTPError.new(uri, resp)
        end
      rescue Timeout::Error, SocketError, Error => e
        if i == 5
          raise FetchError.new(uri, e)
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

    def _find_or_create_site(site_name)
      Site.first(:name => site_name)
    end

    def _find_or_create_category(category_name)
      Category.find_or_create(:name => category_name)
    end
  end

  class << self
    attr_accessor :scraper
  end

  self.scraper = Scraper.new

end

