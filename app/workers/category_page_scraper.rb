
# The CategoryPageScraper scrapes a single page of a category on a site (it
# doesn't scrape the whole category, in other words).
#
class CategoryPageScraper
  include Sidekiq::Worker
  include Hardwarepedia::Sidekiq::Worker

  attr_accessor :site, :category, :page_url
  attr_accessor :site_config, :category_page_config

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

  def perform(site, category, page_url)
    init_with(site, category, page_url)
    visiting(category_page_config, self.page_url, self.category) do
      scrape_page
    end
  end

  def init_with(site, category, page_url)
    self.site = site
    self.category = category
    self.page_url = page_url

    self.site_config = scraper.config.sites[self.site.name]
    # XXX: This fails sporadically?!
    self.category_page_config = site_config.nodes[self.category.name]
  end

  def scrape_page
    category_page_config.product_urls(current_doc).each do |url|
      Hardwarepedia.queue(ProductPageScraper, site.id, category.id, url)
    end
  end
end

