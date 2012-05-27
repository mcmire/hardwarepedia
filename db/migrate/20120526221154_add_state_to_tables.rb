class AddStateToTables < ActiveRecord::Migration
  def change
    change_table :reviewables do |t|
      t.integer :state, :default => 0
    end

    change_table :urls do |t|
      t.integer :state, :default => 0
    end
  end
end
