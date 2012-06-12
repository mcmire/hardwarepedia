
module Hardwarepedia
  class Scraper
    class Configuration
      class DSL
        def initialize(config)
          @config = config
        end

        def evaluate_config_file(config_filename)
          # borrowed from Bundler::Dsl
          config_filename = config_filename.to_s
          instance_eval(File.read(config_filename), config_filename, 1)
        end

        #---

        def retailer(retailer_name, &block)
          retailer = Retailer.new(@config, retailer_name)
          retailer.configure(&block)
          @config.add_retailer(retailer)
        end
      end

      class Retailer
        attr_reader \
          :config,
          :name,
          :base_category_module,
          :category_pages,
          :product_page

        def initialize(config, name)
          @config = config
          @name = name
          @category_pages = []
        end

        def configure(&block)
          instance_eval(&block)
        end

        def base_category(&block)
          @base_category_module = Module.new(&block)
        end

        def category(category_name, &block)
          @category_pages << CategoryPage.new(self, category_name).configure(&block)
        end

        def product(&block)
          @product_page = ProductPage.new(self).configure(&block)
        end
      end

      class CategoryPage
        attr_reader :retailer, :category_name

        def initialize(retailer, category_name)
          @retailer = retailer
          @category_name = category_name
        end

        def doc
          @retailer.config.scraper.doc
        end

        def configure(&block)
          mod = @retailer.base_category_module
          mods = []
          mods << mod if mod
          mods << Module.new(&block)
          extend(*mods)
        end
      end

      class ProductPage
        attr_reader :retailer

        def initialize(retailer)
          @retailer = retailer
        end

        def doc
          @retailer.config.scraper.doc
        end

        def configure(&block)
          extend Module.new(&block)
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
      end

      attr_reader :scraper, :retailers

      def initialize(scraper)
        @scraper = scraper
        @retailers = {}
      end

      def add_retailer(retailer)
        @retailers[retailer.name] = retailer
      end

      def find_retailer(retailer_name)
        @retailers[retailer_name]
      end

      def each_category_page(&block)
        # TODO: Support multiple retailers
        @retailers[@retailers.keys.first].category_pages.each(&block)
      end
    end
  end
end
