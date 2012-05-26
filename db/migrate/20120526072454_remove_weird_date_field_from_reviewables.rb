class RemoveWeirdDateFieldFromReviewables < ActiveRecord::Migration
  def up
    change_table :reviewables do |t|
      t.remove :Date
    end
  end

  def down
    change_table :reviewables do |t|
      t.date :Date
    end
  end
end
