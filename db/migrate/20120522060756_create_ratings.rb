class CreateRatings < ActiveRecord::Migration
  def up
    create_table :ratings do |t|
      t.integer :reviewable_id, :null => false
      t.string :url, :null => false
      t.string :raw_value, :null => false
      t.float :value, :null => false
      t.integer :num_reviews, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
    end
  end

  def down
    drop_table :ratings
  end
end
