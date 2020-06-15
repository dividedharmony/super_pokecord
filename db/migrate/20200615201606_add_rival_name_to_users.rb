# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:users) do
      add_column :rival_name, String, null: true
    end
  end
end
