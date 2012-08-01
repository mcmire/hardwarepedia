
require_dependency 'hardwarepedia/scraper/product_page_scraper'

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

        @thread_count = 0
      end

      def call
        product_urls = _get_category_product_urls()
        _scrape_product_urls(product_urls)
      end

      def _get_category_product_urls
        cached {
          # Visit the first page to get the total number of pages, then use the
          # pagination links on that page to go through the rest of the pages
          # and get a list of product urls
          all_product_urls = []
          @scraper.visiting(@page, @page.page_url(1), 'category') do |doc|
            all_product_urls += @page.product_urls
            _collect_remaining_product_urls!(doc, all_product_urls)
          end
          all_product_urls.sort.uniq
        }
      end

      def _collect_remaining_product_urls!(doc, all_product_urls)
        use_threads = true

        each_url = proc do |page_url|
          @scraper.visiting(@page, page_url, 'category') do |doc|
            all_product_urls += @page.product_urls
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
              @thread_count += 1
              Thread.current[:name] = "T#{@thread_count}"
              begin
                old_each_url.call(page_url)
              rescue Exception => e
                logger.error "#{e.class}: #{e.message}"
                (threads - [Thread.current]).each {|t| t.kill }
                raise e
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
              logger.debug("Finished #{NUM_THREADS} threads in %f seconds (%.1f t/s)" % [elapsed_time, (NUM_THREADS.to_f / elapsed_time)])
            end
          end
        end

        remaining_page_urls = @page.page_urls(2)
        each_urls.call(remaining_page_urls)
      end

      def _scrape_product_urls(all_product_urls)
        use_threads = true #false

        each_url = proc do |product_url|
          ProductPageScraper.new(
            @scraper, @category,
            @page.retailer.product_page, product_url
          ).call
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
              @thread_count += 1
              Thread.current[:name] = "T#{@thread_count}"
              begin
                old_each_url.call(url)
              rescue Exception => e
                logger.error "#{e.class}: #{e.message}"
                (threads - [Thread.current]).each {|t| t.kill }
                raise e
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
              logger.debug("Finished #{NUM_THREADS} threads in %f seconds (%.1f t/s)" % [elapsed_time, (NUM_THREADS.to_f / elapsed_time)])
            end
          end
        end

        each_urls.call(all_product_urls)
      end

      def cached(&block)
        rname = @retailer.name
        cname = @category.name
        if all_product_urls = db.hget(key[:retailers][rname], cname)
          MultiJson.load(all_product_urls)
        else
          all_product_urls = block.call
          db.sadd(key[:retailers], rname)
          db.hset(key[:retailers][rname], cname, MultiJson.dump(all_product_urls))
          db.expire(key[:retailer][rname], EXPIRES_IN)
          all_product_urls
        end
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
