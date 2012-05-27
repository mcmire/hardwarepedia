class GiveProductsIsChipsetAProperDefault < ActiveRecord::Migration
  def up
    change_table :reviewables do |t|
      t.change :is_chipset, :boolean, :default => false, :null => false
    end
  end

  def down
    change_table :reviewables do |t|
      t.change :is_chipset, :boolean, :null => true
    end
  end
end
