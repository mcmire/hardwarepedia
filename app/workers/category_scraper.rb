
class CategoryScraper
  include Sidekiq::Worker
  include Hardwarepedia::Sidekiq::Worker

  attr_accessor :site, :category
  attr_accessor :site_config, :category_config

  def site=(site)
    if Site === site
      @site = site
    else
      @site = Site[site] \
        or raise "Site #{site.inspect} not found!"
    end
    @site
  end

  def category=(category)
    if Category === category
      @category = category
    else
      @category = Category[category] \
        or raise "Category #{category} not found!"
    end
    @category
  end

  def perform(site, category)
    init_with(site, category)
    visiting(category_config, @first_page_url, self.category) do
      _scrape_first_page
      _queue_remaining_pages
    end
  end

  def init_with(site, category)
    self.site = site
    self.category = category

    self.site_config = scraper.config.sites[self.site.name]
    # XXX: This fails sporadically?!
    self.category_config = site_config.nodes[self.category.name]
    @first_page_url = category_config.page_url(current_doc, 1)
  end

  def _scrape_first_page
    # queueing the CategoryPageScraper for this page would visit the page again.
    # we don't want to do that so we need to just parse it directly.
    scraper = CategoryPageScraper.new
    scraper.init_with(site, category, @first_page_url)
    scraper.current_doc = current_doc
    scraper.scrape_page
  end

  def _queue_remaining_pages
    # this implicitly uses the current document (since we are still within a
    # scraper block) to find the total # of pages and generate the rest of the
    # URLs
    category_config.page_urls(current_doc, 2).each do |secondary_page_url|
      Hardwarepedia.queue(CategoryPageScraper, site.id, category.id, secondary_page_url)
    end
  end
end

