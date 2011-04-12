namespace :scrape do
  def fetch(url)
    if u = Url.where(url: url).first
      puts "(Reading #{url} from cache)"
      u.content
    else
      uri = URI.parse(url)
      i = 1
      begin
        full_path = uri.path + (uri.query ? "?#{uri.query}" : "")
        puts "Fetching #{url}..."
        session = Patron::Session.new
        session.timeout = 10
        session.base_url = "#{uri.scheme}://#{uri.host}"
        resp = session.get(full_path)
        if resp.status != 200
          raise "Error fetching #{url}: status code #{resp.status} (#{resp.status_line}; #{resp.url})"
        end
      rescue Patron::TimeoutError => e
        if i == 3
          raise e
        else
          i += 1
          retry
        end
      end
      Url.create!(url: url, content: resp.body)
      resp.body
    end
  end

  def visit(url)
    Nokogiri.parse(fetch(url))
  end
  
  def scrape_product(product_url, category)
    doc = visit(product_url)

    values = doc.xpath('//div[@id="Specs"]//dl/dt | //div[@id="Specs"]//dl/dd').map {|node| node.text.sub(/:$/, "").strip }
    specs = Hash[*values]
    model_name = specs.delete("Model")
    manufacturer_name = specs.delete("Brand")
    if manufacturer_name.blank?
      # Have to do some more sleuthing...
      manufacturer_name = doc.xpath('//div[@id="bcaBreadcrumbTop"]//dd[last()-1]/a/text()').first.text
    end
    full_name = "#{manufacturer_name} #{model_name}"
  
    product = Product.find_or_initialize_by(full_name: full_name)
    product.category = category
    product.manufacturer = Manufacturer.where(name: manufacturer_name).first || begin
      puts "Creating manufacturer '#{manufacturer_name}'"
      Manufacturer.create!(name: manufacturer_name)
    end
    product.name = model_name
    product.content_urls << product_url
    product.specs = specs
    puts "Found product '#{manufacturer_name} #{model_name}'"

    # Are you serious
    sku = doc.at_xpath('//div[@id="bcaBreadcrumbTop"]//dd[last()]').text.sub(/^Item[ ]*#:[ ]*/, "")[1..-1]
    javascript = fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
    json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
    hash = Yajl::Parser.parse(json)
    product.price = hash["finalPrice"]

    rating_node = doc.at_xpath('//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
    # Some products will naturally not have any reviews yet, so there is no rating.
    if rating_node
      product.rating = rating_node.text
      num_reviews_node = rating_node.next
      product.num_reviews = num_reviews_node.text.scan(/\d+/).first
    else
      product.num_reviews = 0
    end

    product.images = []
    #img = doc.at_xpath('//img[@id="mainSlide_0"]')
    #thumb_url = img["src"]
    ## We have the url of the thumbnail but we need a url of the entire image
    #url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
    #unless product.images.where(url: url).exists?
    #  product.images << Image.new(url: url, caption: img["title"])
    #end
    thumb_links = doc.xpath('//ul[contains(@class, "navThumbs")]//a')
    for thumb_link in thumb_links
      # this will give me back xml - i can read the fset element and get dx and dy to get the image dimensions
      "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=fvctx,xml,UTF-8,4&scl=1"
      # this will give me a tile of the image where XXX... is just a random string of chars [0-9A-Za-z_-]
      # and rect is two coords - top left and bottom right
      "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=tile&id=XXXXXXXXXXXXXXXXXXXXXX&rect=0,0,1000,1000"

      # Some products have more than four images. If that's true then another
      # thumbnail image will appear on the page that's an ellipsis icon.
      # This image won't have an onmouseover, so we will want to ignore it.
      if thumb_link["onmouseover"]
        thumb_url = thumb_link["onmouseover"].
          sub(/^Biz\.Product\.DetailPage\.swapProductImageWithLoadding\('/, "").
          sub(/',this\.href,''\);$/, "")
        caption = thumb_link["title"]
        # We have the url of the thumbnail but we need a url of the entire image
        url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
        unless product.images.where(url: url).exists?
          product.images << Image.new(url: url, caption: caption)
        end
      end
    end

    puts "Saving product record for '#{product.full_name}'"
    product.save!
  end
  
  task :init do
    Rake::Task['environment'].invoke
    $stdout.sync = true   # disable buffering
  end
  
  task :products => :init do
    # See product id: 4da11a6d9d0895fb9e00047c -- the manufacturer is blank
    # Can we add some validations?
    
    Manufacturer.delete_all
    Product.delete_all
    
    category_name = "Graphics Cards"
    puts "## About to screenscrape #{category_name}, hold on to your hats..."
    puts "----------"
    
    category = Category.where(name: category_name).first || begin
      puts "Creating category '#{category_name}'"
      Category.create!(name: category_name)
    end
    
    current_page = 1
    total_pages = nil
    until total_pages && current_page > total_pages
      doc = visit("http://www.newegg.com/Store/SubCategory.aspx?SubCategory=48&name=Desktop-Graphics-Video-Cards&Page=#{current_page}")
      total_pages ||= doc.at_xpath('//span[@id="totalPage"]').text.to_i
      
      links = doc.xpath("//span[contains(@class, 'itemDescription')]/parent::a")
      products = []
      links.each do |link|
        product_url = link["href"]
        scrape_product(product_url)
      end
      current_page += 1
      puts "----------"
    end
  end
  
  task :product => :init do
    product_url = ENV["URL"] or raise "Must pass URL=..."
    category_name = ENV["CATEGORY"] or raies "Must pass CATEGORY=..."
    category = Category.where(name: category_name).first
    scrape_product(product_url, category)
  end
end