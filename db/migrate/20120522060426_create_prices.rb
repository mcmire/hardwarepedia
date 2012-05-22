class CreatePrices < ActiveRecord::Migration
  def up
    create_table :prices do |t|
      t.integer :reviewable_id, :null => false
      t.string :url, :null => false
      t.float :amount, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
    end
  end

  def down
    drop_table :prices
  end
end
