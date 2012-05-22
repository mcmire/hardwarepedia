class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.integer :reviewable_id
      t.string :url, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      t.text :caption
    end
  end

  def down
    drop_table :images
  end
end
