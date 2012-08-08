
Sequel.migration do
  change do
    alter_table :urls do
      drop_column :type
      add_column :resource_id, Integer
      add_column :resource_type, String
    end
  end
end
