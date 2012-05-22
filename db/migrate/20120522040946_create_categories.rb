class CreateCategories < ActiveRecord::Migration
  def up
    create_table :categories do |t|
      t.string :name, :null => false
      t.string :webkey, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
    end
  end

  def down
    drop_table :categories
  end
end
