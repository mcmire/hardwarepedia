
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
      u2 = Url.new(content_html)
      if u = Url.find(url)
        # logger.info "Url: #{url}"
        # require 'diffy'
        # diff = Diffy::Diff.new(u.content_html, content_html)
        # puts diff.to_s(:color)
        # exit

        # We've scraped this URL before.
        if true #type == 'product' && u2.content_digest == content_digest
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
          u.content_digest = content_digest
          u.save
          yield doc
          u.state = 1
          u.save
        end
      else
        # We haven't scraped this URL yet, so add it to the database.
        logger.info "Haven't scraped <#{url}> yet, content md5 is #{content_digest}"
        u = Url.create(type, url,
          :content_html => content_html,
          :content => content_digest
        )
        yield doc
        u.state = 1
        u.save
      end
    rescue Error => e
      logger.error e
    end

    def find_or_create_category(category_name)
      Category.find_or_create(category_name)
    end

    def scrape_products
      config.each_category_page do |category_page|
        CategoryPageScraper.new(self, category_page).call
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
  end

end

