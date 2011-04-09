namespace :scrape do
  def fetch(uri)
    if body = CONTENT_CACHE[uri]
      puts "(Reading #{uri} from cache)"
      body
    else
      url = URI.parse(uri)
      session = Patron::Session.new
      session.base_url = "#{url.scheme}://#{url.host}"
      full_path = url.path + (url.query ? "?#{url.query}" : "")
      puts "Fetching #{uri}..."
      resp = session.get(full_path)
      CONTENT_CACHE[uri] = resp.body
      resp.body
    end
  end

  def visit(url)
    Nokogiri.parse(fetch(url))
  end
  
  task :products do
    category = "Graphics Cards"
    doc = visit("http://www.newegg.com/Store/SubCategory.aspx?SubCategory=48&name=Desktop-Graphics-Video-Cards")
    links = doc.xpath("//span[contains(@class, 'itemDescription')]/parent::a")
    products = []
    links.each do |link|
      product_attrs = {
        :category => category,
        :purchase_urls => [],
        :images => []
      }
      product_url = link["href"]
      product_attrs[:purchase_urls] << product_url

      doc2 = visit(product_url)

      values = doc2.xpath('//div[@id="Specs"]//dl/dt | //div[@id="Specs"]//dl/dd').map {|node| node.text.sub(/:$/, "").strip }
      specs = product_attrs[:specs] = Hash[*values]
      product_attrs[:manufacturer] = specs.delete("Brand")
      product_attrs[:model] = specs.delete("Model")

      # Are you serious
      sku = doc2.at_xpath('//div[@id="bcaBreadcrumbTop"]//dd[last()]').text.sub(/^Item[ ]*#:[ ]*/, "")[1..-1]
      javascript = fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
      json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
      hash = Yajl::Parser.parse(json)
      product_attrs[:price] = hash["finalPrice"]

      rating_node = doc2.at_xpath('//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
      product_attrs[:rating] = rating_node.text
      num_reviews_node = rating_node.next
      product_attrs[:num_reviews] = num_reviews_node.text.scan(/\d+/).first

      img = doc2.at_xpath('//img[@id="mainSlide_0"]')
      thumb_url = img["src"]
      # We have the url of the thumbnail but we need a url of the entire image
      url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
      product_attrs[:images] << {
        :url => url ,
        :caption => img["title"]
      }
      thumb_links = doc2.xpath('//ul[contains(@class, "navThumbs")]//a')
      for thumb_link in thumb_links
        # this will give me back xml - i can read the fset element and get dx and dy to get the image dimensions
        "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=fvctx,xml,UTF-8,4&scl=1"
        # this will give me a tile of the image where XXX... is just a random string of chars [0-9A-Za-z_-]
        # and rect is two coords - top left and bottom right
        "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=tile&id=XXXXXXXXXXXXXXXXXXXXXX&rect=0,0,1000,1000"

        thumb_url = thumb_link["onmouseover"].
          sub(/^Biz\.Product\.DetailPage\.swapProductImageWithLoadding\('/, "").
          sub(/',this\.href,''\);$/, "")
        caption = thumb_link["title"]
        # We have the url of the thumbnail but we need a url of the entire image
        url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
        product_attrs[:images] << {:url => url, :caption => caption}
      end

      products << product_attrs

      #pp product_attrs
      #exit
    end

    pp products
  end
end