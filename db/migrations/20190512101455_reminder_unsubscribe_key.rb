# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:users) do
      add_column :reminder_email_unsubscribe_key, String
    end
  end
end
