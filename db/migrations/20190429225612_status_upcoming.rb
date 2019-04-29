# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:shows) do
      set_column_type :status, "enum('Ended','Continuing','Upcoming')"
    end
  end
end
