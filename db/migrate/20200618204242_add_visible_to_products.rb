# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:products) do
      add_column :visible, FalseClass, null: false, default: false
    end
  end
end
