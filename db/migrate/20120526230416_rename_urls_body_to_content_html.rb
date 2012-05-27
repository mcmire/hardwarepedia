class RenameUrlsBodyToContentHtml < ActiveRecord::Migration
  def up
    change_table :urls do |t|
      t.rename :body, :content_html
    end
  end

  def down
    change_table :urls do |t|
      t.rename :content_html, :body
    end
  end
end
