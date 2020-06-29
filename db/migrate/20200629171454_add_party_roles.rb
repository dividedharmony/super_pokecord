# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :party_roles do
      primary_key :id
      column :name, String, null: false, unique: true
      column :primary_role, FalseClass, null: false, default: false
    end
  end
end
