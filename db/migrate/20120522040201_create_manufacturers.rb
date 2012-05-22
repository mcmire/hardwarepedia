class CreateManufacturers < ActiveRecord::Migration
  def up
    create_table :manufacturers do |t|
      t.string :name, :null => false
      t.string :webkey, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      t.string :official_url
    end
  end

  def down
    drop_table :manufacturers
  end
end
