# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:users) do
      add_column :starter_picked, FalseClass, null: false, default: false
    end
  end
end
