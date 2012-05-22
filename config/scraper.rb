
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
