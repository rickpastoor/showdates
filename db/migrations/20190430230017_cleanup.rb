# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:users) do
      drop_column :fbtimeline
    end

    alter_table(:user_show) do
      drop_column :opengraph_id
      drop_column :opengraph_status
    end

    alter_table(:user_episode) do
      drop_column :favorite
    end

    alter_table(:shows) do
      drop_column :needsupdate
    end

    alter_table(:seasons) do
      drop_index :show_url, name: :show_url
      drop_column :url
    end

    alter_table(:networks) do
      drop_index :url, name: :url
      drop_column :url
    end

    alter_table(:genres) do
      drop_column :url
    end
  end
end
