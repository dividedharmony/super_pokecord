# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table(:inventory_items) do
      primary_key :id
      foreign_key :user_id, :users, null: false, index: true
      foreign_key :product_id, :products, null: false, index: true
      column :amount, Integer, null: false, default: 0

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
