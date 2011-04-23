module Pages
  class << self
    attr_accessor :scraper
    
    def each_category_page(&block)
      raise ArgumentError, "No scraper set" unless @scraper
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
      page = build_page(*mods)
      @category_page = page
      
      retailer = (pages[@retailer_name] ||= {})
      retailer[@category_name] = [page]
    end
    def product(&block)
      mod = Module.new(&block)
      page = build_page(mod)
      @category_page.product_page = page
      page.category_page = @category_page
      
      pages[@retailer_name][@category_name][1] = page
    end
    
    def pages
      @pages ||= {}
    end
    
  private
    def build_page(*mods)
      Pages::Page.new(@retailer_name, @category_name).tap do |page|
        mods.each {|mod| page.extend(mod) }
      end
    end
  end
  
  class Page
    attr_accessor :retailer_name, :category_name, :category_page, :product_page
    
    def initialize(retailer_name, category_name)
      @retailer_name = retailer_name
      @category_name = category_name
    end
    
    def logger
      @logger ||= Hardwarepedia::Logger.instance
    end
    
    def scraper
      Pages.scraper
    end
  end
  
  #---
  
  retailer "Newegg" do
    base_category do
      def page_urls(start_page_number)
        (start_page_number..scraper.total_num_pages).to_a.map {|i| page_url(i) }
      end
      
      def page_url(page_number=1)
        "http://www.newegg.com/Store/SubCategory.aspx?SubCategory=#{id}&Page=#{page_number}"
      end
      
      def product_urls
        scraper.doc.xpath("//span[contains(@class, 'itemDescription')]/parent::a").map {|link| link["href"] }
      end
  
      def content_xpath
        %{//div[@id="bcaProductCell"]}
      end
    end
    category "Graphics Cards" do
      def id; 48; end
    end
    product do
      def content_xpath
        %{//div[@id="bodyCenterArea"]}
      end
    end
  end
end