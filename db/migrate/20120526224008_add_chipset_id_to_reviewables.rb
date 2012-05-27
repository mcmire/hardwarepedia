class AddChipsetIdToReviewables < ActiveRecord::Migration
  def change
    change_table :reviewables do |t|
      t.integer :chipset_id
    end
  end
end
