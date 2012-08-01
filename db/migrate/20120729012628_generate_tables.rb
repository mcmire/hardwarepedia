
Sequel.migration do
  change do
    create_table! :categories do
      primary_key :id
      String :name, :null => false, :unique => true
      String :webkey, :null => false, :unique => true
      index :webkey
      Integer :state, :null => false
      index :state
      Time :created_at, :null => false
      Time :updated_at, :null => false
    end

    create_table! :manufacturers do
      primary_key :id
      String :name, :null => false, :unique => true
      String :webkey, :null => false, :unique => true
      index :webkey
      Time :created_at, :null => false
      Time :updated_at, :null => false
    end

    create_table! :urls do
      primary_key :id
      String :type, :null => false
      index :type
      String :url, :null => false, :unique => true
      String :content_html, :null => false
      String :content_digest, :null => false
      Integer :state, :null => false
      index :state
      Time :created_at, :null => false
      Time :updated_at, :null => false
      Time :expires_at, :null => false
    end

    create_table! :reviewables do
      primary_key :id
      String :type, :null => false
      index :type
      String :full_name, :unique => true
      index :full_name
      String :webkey, :null => false, :unique => true
      Integer :state, :null => false
      index :state
      Integer :num_prices, :null => false
      Time :created_at, :null => false
      Time :updated_at, :null => false
      # will be checked for presence manually:
      Integer :manufacturer_id
      foreign_key [:manufacturer_id], :manufacturers
      Integer :category_id
      foreign_key [:category_id], :categories
      String :name
      String :specs, :text => true
      String :content_urls, :text => true
      # optional attrs
      Integer :chipset_id
      foreign_key [:chipset_id], :reviewables
      String :summary
      Integer :num_reviews
      Date :released_to_market_on
      String :official_urls, :text => true
      String :mention_urls, :text => true
    end

    create_table! :images do
      primary_key :id
      Integer :reviewable_id, :null => false
      foreign_key [:reviewable_id], :reviewables
      String :reviewable_url, :null => false
      String :url, :null => false, :unique => true
      String :caption
      Time :created_at, :null => false
      Time :updated_at, :null => false
    end

    create_table! :prices do
      primary_key :id
      Integer :reviewable_id, :null => false
      foreign_key [:reviewable_id], :reviewables
      String :reviewable_url, :null => false, :unique => true
      Integer :amount, :null => false
      Time :created_at, :null => false
      Time :updated_at, :null => false
    end

    create_table! :ratings do
      primary_key :id
      Integer :reviewable_id, :null => false
      foreign_key [:reviewable_id], :reviewables
      String :reviewable_url, :null => false, :unique => true
      String :raw_value, :null => false
      Float :value, :null => false
      Integer :num_reviews, :null => false
      Time :created_at, :null => false
      Time :updated_at, :null => false
    end
  end
end

