site 'Newegg' do
  node_type :category do
    def total_num_pages
      @total_num_pages ||= begin
        text = doc.at_xpath(".//div[contains(@class, 'recordCount')]").text
        match = text.match(/Showing \s* (\d+)-(\d+) \s* of \s* (\d+)/x)
        start, finish, count = match.captures.map(&:to_i)
        count / (finish - start + 1)  # auto-floor
      end
    end

    def page_urls(start_page_number)
      (start_page_number..total_num_pages).to_a.map {|i| page_url(i) }
    end

    def page_url(page_number=1)
      "http://www.newegg.com/Store/SubCategory.aspx?SubCategory=#{get(:id)}&Page=#{page_number}"
    end

    def product_urls
      doc.xpath(".//span[contains(@class, 'itemDescription')]/parent::a").map {|link| link["href"] }
    end

    def content_xpath
      %{.//div[@id="categoryNavTop"] | .//div[@id="bcaProductCell"]}
    end

    def preprocess!(node_set)
      # Remove the featured product from the product page as that is going to
      # change every refresh
      xpath = %{.//div[contains(@class, "itemCell") and contains(@class, "featuredProduct")]}
      if node = node_set.at_xpath(xpath)
        node.unlink
      end
      if node_set.at_xpath(xpath)
        raise 'Ugh, featuredProduct never got removed'
      end
    end
  end

  category 'Graphics Cards' do
    set :id => 48

    node :product do
      def content_xpath
        %{//div[@id="bodyCenterArea"]}
      end
    end
  end
end
