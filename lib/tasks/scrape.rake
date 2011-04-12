namespace :scrape do
  task :init do
    Rake::Task['environment'].invoke
    $stdout.sync = true   # disable buffering
  end
  
  task :products => :init do
    puts "Clearing out manufacturers and products..."
    Manufacturer.delete_all
    Product.delete_all
    
    Hardwarepedia::Scraper.new.scrape_products
  end
  
  task :product => :init do
    product_url = ENV["URL"] or raise "Must pass URL=..."
    category_name = ENV["CATEGORY"] or raies "Must pass CATEGORY=..."
    category = Category.where(name: category_name).first
    Hardwarepedia::Scraper.new.scrape_product(product_url, category)
  end
end