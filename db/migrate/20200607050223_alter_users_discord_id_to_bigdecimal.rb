# frozen_string_literal: true

ROM::SQL.migration do
  up do
    alter_table(:users) do
      set_column_type :discord_id, String
    end
  end

  down do
    run 'ALTER TABLE users ALTER COLUMN discord_id TYPE integer USING discord_id::integer'
  end
end
