class CreateReviewables < ActiveRecord::Migration
  def up
    create_table :reviewables do |t|
      t.string :name, :null => false
      t.string :full_name, :null => false
      t.string :webkey, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false

      t.string :summary
      t.string :specs, :default => {}
      t.integer :num_reviews
      t.string :content_urls, :default => Set.new
      t.string :official_urls, :default => Set.new
      t.string :mention_urls, :default => Set.new
      t.date :market_released_on, Date
      t.float :aggregated_score
      t.boolean :is_chipset
    end
  end

  def down
    drop_table :reviewables
  end
end
