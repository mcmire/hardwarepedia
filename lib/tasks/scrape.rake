namespace :scrape do
  task :init do
    Rake::Task['environment'].invoke
    $stdout.sync = true   # disable buffering
  end
  
  task :products => :init do
    #puts "Clearing out manufacturers and products..."
    #Manufacturer.delete_all
    #Product.delete_all
    #Url.delete_all
    
    Hardwarepedia::Scraper.new.scrape_products
  end
  
  task :product => :init do
    product_url = ENV["URL"] or raise "Must pass URL=..."
    retailer_name = "Newegg"
    category_name = "Graphics Cards"
    
    category = Category.where(name: category_name).first
    Hardwarepedia::Scraper.new.scrape_product(retailer_name, category_name, product_url)
  end
end