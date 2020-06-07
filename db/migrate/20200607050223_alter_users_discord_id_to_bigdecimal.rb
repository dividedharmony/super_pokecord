# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:users) do
      set_column_type :discord_id, String
    end
  end
end
