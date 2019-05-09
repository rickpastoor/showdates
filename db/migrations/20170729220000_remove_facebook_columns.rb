# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:users) do
      drop_column :facebook_access_token
      drop_column :facebook_token_expires
    end
  end

  down do
    alter_table(:users) do
      add_column :facebook_access_token, 'varchar(255)'
      add_column :facebook_token_expires, 'int(11)'
    end
  end
end
