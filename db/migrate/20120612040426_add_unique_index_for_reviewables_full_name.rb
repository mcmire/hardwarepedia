class AddUniqueIndexForReviewablesFullName < ActiveRecord::Migration
  def up
    change_table :reviewables do |t|
      t.index :full_name, :unique => true
    end
  end

  def down
    change_table :reviewables do |t|
      t.remove_index :full_name
    end
  end
end
