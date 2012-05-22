class CreateReviewables < ActiveRecord::Migration
  def up
    create_table :reviewables do |t|
      t.string :type, :null => false
      t.integer :category_id, :null => false
      t.integer :manufacturer_id, :null => false
      t.string :name, :null => false
      t.string :full_name, :null => false
      t.string :webkey, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false

      t.text :summary
      t.text :specs, :default => {}
      t.integer :num_reviews
      t.text :content_urls, :default => Set.new
      t.text :official_urls, :default => Set.new
      t.text :mention_urls, :default => Set.new
      t.date :market_released_on, Date
      t.float :aggregated_score
      t.boolean :is_chipset
    end
  end

  def down
    drop_table :reviewables
  end
end
