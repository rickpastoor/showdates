Sequel.migration do
  up do
    alter_table(:users) do
      add_column :password_migrated, :boolean, :default => false
      add_column :salt, "varchar(255)"
    end
  end

  down do
    alter_table(:users) do
      drop_column :password_migrated
      drop_column :salt
    end
  end
end
