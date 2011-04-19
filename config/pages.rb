module Pages
  class << self
    attr_accessor :scraper
    
    def each_category_page(&block)
      raise "No scraper set" unless @scraper
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
    def category(category_name, &block)
      @category_name = category_name
      yield
    end
    def products(&block)
      page = build_page(&block)
      @category_page = page
      
      retailer = (pages[@retailer_name] ||= {})
      retailer[@category_name] = [page]
    end
    def product(&block)
      page = build_page(&block)
      @category_page.product_page = page
      page.category_page = @category_page
      
      pages[@retailer_name][@category_name][1] = page
    end
    
    def pages
      @pages ||= {}
    end
    
  private
    def build_page(&block)
      page = Pages::Page.new
      page.instance_eval(&block)
      page.retailer_name = @retailer_name
      page.category_name = @category_name
      page
    end
  end
  
  class Page
    attr_accessor :retailer_name, :category_name, :category_page, :product_page
    
    def scraper; Pages.scraper; end
  end
  
  #---
  
  retailer "Newegg" do
    category "Graphics Cards" do
      products do
        def url
          "http://www.newegg.com/Store/SubCategory.aspx?SubCategory=48&Page=#{scraper.data[:page] ||= 1}"
        end
    
        def content_xpath
          %{//div[@id="bcaProductCell"]}
        end
      
        def next_url?
          scraper.data[:page] += 1
          scraper.data[:page] <= total_pages
        end
    
        def total_pages
          @total_pages ||= scraper.doc.at_xpath('//span[@id="totalPage"]').text.to_i
        rescue NoMethodError => e
          puts "Content:"
          puts scraper.doc.to_html
          raise e
        end
      
        def product_urls
          scraper.doc.xpath("//span[contains(@class, 'itemDescription')]/parent::a").map {|link| link["href"] }
        end
      end
      product do
        def url
          "http://www.newegg.com/Product/Product.aspx?Item=#{scraper.data[:sku]}"
        end
        
        def content_xpath
          %{//div[@id="bodyCenterArea"]}
        end
      end
    end
  end
end