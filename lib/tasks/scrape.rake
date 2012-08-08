
namespace :scrape do
  task :init => [:environment, 'redis:start'] do
    $stdout.sync = true   # disable buffering

=begin
    if Rails.env.production?
      # Load all the eager load paths since Rails does not do this when running
      # Rake tasks, even in production mode
      Dir[ Rails.root.join("lib/hardwarepedia/**/*.rb") ].each {|fn| require_dependency fn }
      Dir[ Rails.root.join("app/models/**/*.rb") ].each {|fn| require_dependency fn }
    else
      # Load all the models since we're getting an error accessing the Product
      # model when screenscraping product pages:
      # "LoadError: Expected app/models/product.rb to define Product"
      Dir[ Rails.root.join("app/models/**/*.rb") ].each {|fn| require_dependency fn }
    end
=end
  end

  def clear_all_the_things
    start_over = false
    puts "Clearing out everything first..."
    Image.delete_all
    Price.delete_all
    Rating.delete_all
    Reviewable.delete_all
    Category.delete_all
    Manufacturer.delete_all
    if start_over
      Url.delete_all
      Hardwarepedia::Scraper::CategoryPageScraper.clear_cache
    else
      Url.delete_all(:type => 'Product')
    end
  end

  def clear_product(product, url)
    # product.destroy if product
    url.destroy if url
  end

  task :products => :init do
    clear_all_the_things
    Hardwarepedia::Scraper.new.scrape_products
  end

  task :product => :init do
    args = {}
    args[:url] = ENV['URL']
    args[:webkey] = ENV['WEBKEY']

    unless args[:url] or args[:webkey]
      raise ArgumentError, "Must pass URL=... or WEBKEY=..."
    end

    if url = args[:url]
      u = Url.first(:url => url)
      p = u.resource if u
    elsif args[:webkey]
      if p = Reviewable.first(:type => 'product', :webkey => args[:webkey])
        url = p.content_urls.first
        u = Url.first(:url => url)
      else
        raise "Can't find a product by #{args[:webkey]}"
      end
    end

    clear_product(p, u)

    retailer_name = "Newegg"
    category_name = "Graphics Cards"
    scraper = Hardwarepedia::Scraper.new
    scraper.scrape_product(retailer_name, category_name, url)
  end

  task :failed => :init do
    scraper = Hardwarepedia::Scraper.new
    Reviewable.where(:state => 1).each do |rev|
      scraper.scrape_product('Newegg', 'Graphics Cards', rev.official_urls[0])
    end
  end
end
