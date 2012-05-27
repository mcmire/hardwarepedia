class LoosenReviewablesPresenceRestrictions < ActiveRecord::Migration
  def up
    change_table :reviewables do |t|
      t.change :manufacturer_id, :integer, :null => true
    end
  end

  def down
    change_table :reviewables do |t|
      t.change :manufacturer_id, :integer, :null => false
    end
  end
end
