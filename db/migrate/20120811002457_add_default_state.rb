Sequel.migration do
  up do
    alter_table :categories do
      set_column_default :state, 0
    end
    alter_table :urls do
      set_column_default :state, 0
    end
    alter_table :reviewables do
      set_column_default :state,  0
    end
  end

  down do
    alter_table :add_default_states do
      set_column_default :state, nil
    end
    alter_table :urls do
      set_column_default :state, nil
    end
    alter_table :reviewables do
      set_column_default :state, nil
    end
  end
end
