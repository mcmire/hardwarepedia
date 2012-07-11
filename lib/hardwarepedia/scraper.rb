
require 'net/http'
require 'enumerator'

require_dependency 'hardwarepedia/scraper/configuration'
require_dependency 'hardwarepedia/scraper/category_page_scraper'

require_dependency 'url'
require_dependency 'category'

module Hardwarepedia

  class Scraper
    LOG_FILENAME = Rails.root.join('log/scraper.log')
    # This is the max we can go before Postgres barfs
    # TODO: Raise max_connections in postgresql.conf??
    NUM_THREADS = 10  #20

    class Error < StandardError; end

    attr_reader :data, :doc, :total_num_pages

    def initialize
      @data = {}
    end

    def config
      @config ||= Configuration.build(self)
    end

    def logger
      # Q: Will this also write to the root logger file?
      @logger ||= Logging.logger[self].tap do |logger|
        file_appender = Logging.appenders.file(LOG_FILENAME)
        logger.add_appenders(file_appender)
      end
    end

    def visiting(page, url, type, &block)
      body = fetch(url)
      @doc = doc = Nokogiri.parse(body)
      node_set = doc.xpath(page.content_xpath)
      unless node_set
        raise Error, "Couldn't find content at <#{page.content_xpath}>!"
      end

      # Remove script and style tags
      node_set.xpath('.//script | .//style').unlink

      page.preprocess!(node_set) if page.respond_to?(:preprocess!)
      content_html = node_set.to_html
      u2 = Url.new(
        :type => type,
        :url => url,
        :content_html => content_html
      )
      if u = Url.with(:url, url)
        # logger.debug "Url: #{url}"
        # require 'diffy'
        # diff = Diffy::Diff.new(u.content_html, u2.content_html)
        # puts diff.to_s(:color)
        # exit

        # We've scraped this URL before.
        if true #type == 'product' && u.content_digest == u2.content_digest
          # The content of this page hasn't changed since we last scraped it,
          # so no need to scrape it again
          if type == 'category'
            logger.debug "Already scraped <#{url}>, but going to process anyway since it's a category page"
            u.state = 0
            u.save
            yield doc
            u.state = 1
            u.save
          else
            logger.debug "Already scraped <#{url}>, and it hasn't changed since last scrape, proceeding"
          end
        else
          # The content of the page *has* changed since we last scraped it,
          # so just update the signature of the content
          if type == 'product'
            logger.debug "Already scraped <#{url}>, but it's changed since last scrape, so updating md5"
          else
            logger.debug "Scraping <#{url}> regardless of content since it's a collection page"
          end
          u.state = 0
          u.content_digest = u2.content_digest
          u.save
          yield doc
          u.state = 1
          u.save
        end
      else
        u = u2
        # We haven't scraped this URL yet, so add it to the database.
        logger.debug "Haven't scraped <#{url}> yet, content md5 is #{u.content_digest}"
        u.save
        yield doc
        u.state = 1
        u.save
      end
    rescue Error => e
      logger.error e
    end

    def find_or_create_category(category_name)
      Category.first_or_create(:name => category_name, :state => 1)
    end

    def scrape_product(retailer_name, category_name, product_url)
      retailer = config.find_retailer(retailer_name)
      category = find_or_create_category(category_name)
      product_page_scraper = Hardwarepedia::Scraper::ProductPageScraper.new(
        self, category, retailer.product_page, product_url
      )
      product_page_scraper.call
    end

    def scrape_products
      config.each_category_page do |category_page|
        CategoryPageScraper.new(self, category_page).call
      end
    end

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
  end

end

