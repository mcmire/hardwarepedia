site 'Newegg' do
  node_type :category do
    def total_num_pages(doc)
      @total_num_pages ||= begin
        text = doc.at_xpath(".//div[contains(@class, 'recordCount')]").text
        match = text.match(/Showing \s* \d+-(\d+) \s* of \s* (\d+)/x)
        per_page, total = match.captures.map(&:to_i)
        (total.to_f / per_page).ceil
      end
    end

    def page_urls(doc, start_page_number)
      (start_page_number..total_num_pages(doc)).to_a.map {|i| page_url(doc, i) }
    end

    def page_url(doc, page_number=1)
      "http://www.newegg.com/Store/SubCategory.aspx?SubCategory=#{get(:id)}&Page=#{page_number}"
    end

    def product_urls(doc)
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
