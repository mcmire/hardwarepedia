
require_dependency 'hardwarepedia/scraper/product_page_scraper'
require_dependency 'hardwarepedia/batch_processor'
require_dependency 'hardwarepedia/threaded_batch_processor'

module Hardwarepedia
  class Scraper

    class CategoryPageScraper
      KEY_NS = 'retailer_category_product_urls'
      EXPIRES_IN = 1.day

      def self.clear_cache
        db.smembers(key[:retailers]).each do |rname|
          db.del(key[:retailers][rname])
        end
        db.del(key[:retailers])
      end

      def self.db
        Hardwarepedia.redis
      end

      def self.key
        @key ||= Nest.new(KEY_NS, db)
      end

      attr_reader :scraper, :page, :retailer, :category

      def initialize(scraper, page)
        @scraper = scraper
        @page = page

        @retailer = @page.retailer
        @category = @scraper.find_or_create_category(@page.category_name)

        @all_product_urls = []

        @use_threads = true
      end

      def call
        _get_category_product_urls()
        _scrape_product_urls()
      end

      def _processor_class
        @use_threads ? ThreadedBatchProcessor : BatchProcessor
      end

      def _get_category_product_urls
        if product_urls = _fetch_cached_product_urls
          @product_urls = product_urls
        else
          # Visit the first page to get the total number of pages, then use the
          # pagination links on that page to go through the rest of the pages
          # and get a list of product urls
          @scraper.visiting(@page, @page.page_url(1)) do |url, doc|
            url.resource = @category
            @product_urls.concat(@page.product_urls)
            _collect_remaining_product_urls!
          end
          @product_urls = @product_urls.sort.uniq
          _cache_product_urls(@product_urls)
        end
      end

      def _fetch_cached_product_urls
        if product_urls = db.hget(key[:retailers][@retailer.name], @category.name)
          MultiJson.load(product_urls)
        end
      end

      def _cache_product_urls(product_urls)
        rname = @retailer.name
        cname = @category.name
        db.sadd(key[:retailers], rname)
        db.hset(key[:retailers][rname], cname, MultiJson.dump(all_product_urls))
        db.expire(key[:retailer][rname], EXPIRES_IN)
      end

      def _collect_remaining_product_urls!
        remaining_page_urls = @page.page_urls(2)
        _processor_class.call(self, remaining_page_urls, :_scrape_category_url)
      end

      def _scrape_category_url(url)
        @scraper.visiting(@page, url) do
          url.resource = @category
          @product_urls.concat(@page.product_urls)
        end
      end

      def _scrape_product_urls
        _processor_class.call(self, @product_urls, :_scrape_product_url)
      end

      def _scrape_product_url(url)
        ProductPageScraper.call \
          @scraper,
          @category,
          @page.retailer.product_page,
          url
      end

      def key
        self.class.key
      end

      def db
        self.class.db
      end
    end

  end
end
