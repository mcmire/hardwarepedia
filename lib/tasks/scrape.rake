
namespace :scrape do
  task :init => :environment do
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
    puts "Clearing out everything first..."
    Manufacturer.delete_all
    Category.delete_all
    Reviewable.delete_all
    Url.delete_all
    # Hardwarepedia::Scraper::CategoryPageScraper.clear_cache
  end

  task :products => :init do
    clear_all_the_things
    Hardwarepedia::Scraper.new.scrape_products
  end

  task :product => :init do
    product_url = ENV["URL"] or raise "Must pass URL=..."
    retailer_name = "Newegg"
    category_name = "Graphics Cards"

    # clear_all_the_things

    scraper = Hardwarepedia::Scraper.new
    retailer = scraper.config.find_retailer(retailer_name)
    product_page_scraper = Hardwarepedia::Scraper::ProductPageScraper.new(
      scraper, retailer.product_page, product_url
    )
    product_page_scraper.call
  end
end
