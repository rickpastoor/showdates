Sequel.migration do
  up do
    alter_table(:networks) do
      add_column :icon, "varchar(255)"
    end
  end

  down do
    alter_table(:networks) do
      drop_column :icon
    end
  end
end
