Sequel.migration do
  up do
    create_table(:categories) do
      primary_key :id
      column :name, "text", :null=>false
      column :webkey, "text", :null=>false
      column :state, "integer", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:name], :name=>:categories_name_key, :unique=>true
      index [:state]
      index [:webkey]
      index [:webkey], :name=>:categories_webkey_key, :unique=>true
    end
    
    create_table(:manufacturers) do
      primary_key :id
      column :name, "text", :null=>false
      column :webkey, "text", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:name], :name=>:manufacturers_name_key, :unique=>true
      index [:webkey]
      index [:webkey], :name=>:manufacturers_webkey_key, :unique=>true
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:urls) do
      primary_key :id
      column :url, "text", :null=>false
      column :content_html, "text", :null=>false
      column :content_digest, "text", :null=>false
      column :state, "integer", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      column :expires_at, "timestamp without time zone", :null=>false
      column :resource_id, "integer"
      column :resource_type, "text"
      
      index [:state]
      index [:url], :name=>:urls_url_key, :unique=>true
    end
    
    create_table(:reviewables) do
      primary_key :id
      column :type, "text", :null=>false
      column :full_name, "text"
      column :webkey, "text", :null=>false
      column :state, "integer", :null=>false
      column :num_prices, "integer", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      foreign_key :manufacturer_id, :manufacturers, :key=>[:id]
      foreign_key :category_id, :categories, :key=>[:id]
      column :name, "text"
      column :specs, "text"
      column :content_urls, "text"
      foreign_key :chipset_id, :reviewables, :key=>[:id]
      column :summary, "text"
      column :num_reviews, "integer"
      column :released_to_market_on, "date"
      column :official_urls, "text"
      column :mention_urls, "text"
      
      index [:full_name]
      index [:full_name], :name=>:reviewables_full_name_key, :unique=>true
      index [:state]
      index [:type]
      index [:webkey], :name=>:reviewables_webkey_key, :unique=>true
    end
    
    create_table(:images) do
      primary_key :id
      foreign_key :reviewable_id, :reviewables, :null=>false, :key=>[:id]
      column :reviewable_url, "text", :null=>false
      column :url, "text", :null=>false
      column :caption, "text"
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:url], :name=>:images_url_key, :unique=>true
    end
    
    create_table(:prices) do
      primary_key :id
      foreign_key :reviewable_id, :reviewables, :null=>false, :key=>[:id]
      column :reviewable_url, "text", :null=>false
      column :amount, "integer", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:reviewable_url], :name=>:prices_reviewable_url_key, :unique=>true
    end
    
    create_table(:ratings) do
      primary_key :id
      foreign_key :reviewable_id, :reviewables, :null=>false, :key=>[:id]
      column :reviewable_url, "text", :null=>false
      column :raw_value, "text", :null=>false
      column :value, "double precision", :null=>false
      column :num_reviews, "integer", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:reviewable_url], :name=>:ratings_reviewable_url_key, :unique=>true
    end
  end
  
  down do
    drop_table(:ratings, :prices, :images, :reviewables, :urls, :schema_migrations, :manufacturers, :categories)
  end
end
