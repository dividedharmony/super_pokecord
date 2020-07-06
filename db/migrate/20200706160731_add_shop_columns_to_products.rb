# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:products) do
      add_column :price, Integer, null: false, default: 0
      add_column :page_num, Integer, null: false, default: 0
      add_column :position, Integer, null: false, default: 0
    end
  end
end
