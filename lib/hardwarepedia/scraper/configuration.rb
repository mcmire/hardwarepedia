
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

        def site(name, &block)
          site = Node.new(@config, name, &block)
          @config.add_site(site)
        end
      end

      #---

      class Node
        attr_reader :parent, :name, :nodes

        def initialize(parent, name, &block)
          @parent = parent
          @name = name
          @vars = {}
          @nodes = []
          configure(&block) if block
        end

        def configure(&block)
          instance_eval(&block)
        end

        def get(name)
          @vars[name.to_sym]
        end

        def set(name, val)
          if Hash === val
            val.each {|k,v| set(k, v) }
          else
            @vars[name.to_sym] = val
          end
        end

        def node_type(name, &type_block)
          @node_types[name] = type_block
          singleton_class.send(:define_method, name) do |&block|
            node(name).tap do |n|
              n.configure(&type_block)
              n.configure(&block)
            end
          end
        end

        def node(name, &block)
          @nodes << Node.new(self, name, &block)
        end

        def content_xpath
          raise NotImplementedError, "#content_xpath must be defined in your node block"
        end
      end

      #---

      def self.build(scraper)
        Configuration.new(scraper).tap do |config|
          dsl = DSL.new(config)
          config_file = Rails.root.join('config/scraper.rb')
          dsl.evaluate_config_file(config_file)
        end
      end

      #---

      attr_reader :scraper, :sites

      def initialize(scraper)
        @scraper = scraper
        @sites = {}
      end

      def add_site(site)
        @sites[site.name] = site
      end

      def each_category_page(&block)
        # TODO: Support multiple sites
        @sites[@sites.keys.first].category_pages.each(&block)
      end
    end
  end
end
