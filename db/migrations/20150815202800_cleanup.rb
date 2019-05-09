# frozen_string_literal: true

Sequel.migration do
  up do
    drop_table?(:log, :role_cmspage, :cmspage, :access, :celer_migration, :user_role, :role)
    rename_table(:user, :users)
    rename_table(:episode, :episodes)
    rename_table(:genre, :genres)
    rename_table(:network, :networks)
    rename_table(:season, :seasons)
    rename_table(:show, :shows)
  end

  down do
    # Irreversible
  end
end
