# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:users) do
      add_column :avatar, 'varchar(255)'
    end
  end

  down do
    alter_table(:users) do
      drop_column :avatar
    end
  end
end
