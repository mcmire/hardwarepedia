
class CategoryPageScraper
  include Hardwarepedia::Sidekiq::Worker

  def perform(site_id, category_id, page_number=1)
    @site = Site[site_id]
    @category = Category[category_id]
    @page_number = page_number
    @category_url = category_page.page_url(@page_number)

    site_config = scraper.config.sites[site.name]
    @category_page = site_config.nodes[category.name]

    _scrape_category or return

    Hardwarepedia.queue(CategoryPageScraper, @site.id, @category.id, @page_number + 1)
  end

  def category_url_hash
    @category_url_hash ||= Digest::MD5.hexdigest(@category_url)
  end

  def product_urls
    redis_key[category_url_hash][:product_urls]
  end

  def _scrape_category
    scraper.visiting(@category_page, @category_url) do |ourl, doc|
      ourl.resource = @category
      @category_page.product_urls.each do |url|
        Hardwarepedia.queue(ProductPageScraper, @site.id, @category.id, url)
      end
    end
  rescue Scraper::Error # not found
    return false
  end
end
