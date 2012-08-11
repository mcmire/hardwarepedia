
# The CategoryPageScraper scrapes a single page of a category on a site (it
# doesn't scrape the whole category, in other words).
#
class CategoryPageScraper
  include Hardwarepedia::Sidekiq::Worker

  def perform(site_id, category_id, page_number=1)
    pp :site_id => site_id, :category_id => category_id

    @site = Site[site_id]
    @category = Category[category_id]
    @page_number = page_number

    site_config = scraper.config.sites[@site.name]
    @category_page = site_config.nodes[@category.name]

    @category_url = @category_page.page_url(@page_number)

    _scrape_category or return

    Hardwarepedia.queue(CategoryPageScraper, @site.id, @category.id, @page_number + 1)
  end

  def category_url_hash
    @category_url_hash ||= Digest::MD5.hexdigest(@category_url)
  end

  def _scrape_category
    scraper.visiting(@category_page, @category_url) do |ourl, doc|
      ourl.resource = @category
      @category_page.product_urls.each do |url|
        Hardwarepedia.queue(ProductPageScraper, @site.id, @category.id, url)
      end
    end
  rescue Hardwarepedia::Scraper::Error => err   # not found, or something else
    logger.error(err)
    return false
  end
end

