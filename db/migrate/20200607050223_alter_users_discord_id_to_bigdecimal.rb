# frozen_string_literal: true

ROM::SQL.migration do
  up do
    alter_table(:users) do
      set_column_type :discord_id, String
    end
  end

  down do
    alter_table(:users) do
      drop_column :discord_id
      add_column :discord_id, Integer, null: false, default: 0
    end
  end
end
