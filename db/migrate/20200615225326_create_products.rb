# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :products do
      primary_key :id
      column :name, String, null: false, unique: true
    end
  end
end
