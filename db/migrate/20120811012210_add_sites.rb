Sequel.migration do
  up do
    create_table :sites do
      primary_key :id
      String :name, :null => false, :unique => true
      String :webkey, :null => false, :unique => true
      String :root_url, :null => false
    end
  end

  down do
    drop_table :sites
  end
end
