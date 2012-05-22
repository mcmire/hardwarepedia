class CreateUrls < ActiveRecord::Migration
  def up
    create_table :urls do |t|
      t.string :url, :null => false
      t.text :body, :null => false
      t.string :content_md5, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
    end
  end

  def down
    drop_table :urls
  end
end
