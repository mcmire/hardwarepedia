
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
    Image.delete_all
    Price.delete_all
    Rating.delete_all
    Reviewable.delete_all
    Category.delete_all
    Manufacturer.delete_all
    Url.delete_all(:type => 'product')
    # Hardwarepedia::Scraper::CategoryPageScraper.clear_cache
  end

  task :products => :init do
    clear_all_the_things
    Hardwarepedia::Scraper.new.scrape_products
  end

  task :product => :init do
    retailer_name = "Newegg"
    category_name = "Graphics Cards"
    product_url = ENV["URL"] or raise "Must pass URL=..."

    clear_all_the_things

    scraper = Hardwarepedia::Scraper.new
    scraper.scrape_product(retailer_name, category_name, product_url)
  end
end
