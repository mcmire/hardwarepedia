
module Hardwarepedia
  class Scraper
    class Configuration
      class DSL
        def initialize(config)
          @config = config
        end

        def evaluate_config_file(config_file)
          # borrowed from Bundler::Dsl
          instance_eval(File.read(config_file), config_file, 1)
        end

        #---

        def retailer(retailer_name)
          @retailer_name = retailer_name
          yield
        end

        def base_category(&block)
          @base_category = Module.new(&block)
        end

        def category(category_name, &block)
          @category_name = category_name
          mods = [ @base_category, Module.new(&block) ].compact
          page = @config.build_page(@retailer_name, @category_name, mods)
          @category_page = page

          retailer = (pages[@retailer_name] ||= {})
          retailer[@category_name] = [page]
        end

        def product(&block)
          mod = Module.new(&block)
          page = @config.build_page(@retailer_name, @category_name, [mod])
          @category_page.product_page = page
          page.category_page = @category_page

          pages[@retailer_name][@category_name][1] = page
        end
      end

      class Page
        attr_accessor :retailer_name, :category_name, :category_page, :product_page

        def initialize(config, retailer_name, category_name)
          @config = config
          @retailer_name = retailer_name
          @category_name = category_name
        end

        def logger
          @config.logger
        end

        def scraper
          @config.scraper
        end
      end

      class << self
        def build(scraper)
          Configuration.new(scraper).tap do |config|
            dsl = DSL.new(config)
            config_file = Rails.root.join('config/scraper.rb')
            dsl.evaluate_config_file(config_file)
          end
        end

        def logger
          Logging.logger[self]
        end
      end

      def initialize(scraper)
        @scraper = scraper
      end

      def each_category_page(&block)
        pages.each do |retailer_name, categories|
          categories.each do |category_name, (category_page, product_page)|
            yield category_page
          end
        end
      end

      def find_category(retailer_name, category_name)
        @pages[retailer_name][category_name][0]
      rescue NoMethodError
        nil
      end

      def find_product(retailer_name, category_name)
        @pages[retailer_name][category_name][1]
      rescue NoMethodError
        nil
      end

      def pages
        @pages ||= {}
      end

      def build_page(retailer_name, category_name, mods)
        Page.new(self, retailer_name, category_name).tap do |page|
          mods.each {|mod| page.extend(mod) }
        end
      end

      def logger
        self.class.logger
      end
    end
  end
end
