# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :trades do
      primary_key :id
      foreign_key :user_1_id, :users, null: false, index: true
      foreign_key :user_2_id, :users, null: true, index: true
      column :user_1_confirm, FalseClass, null: false, default: false
      column :user_2_confirm, FalseClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
      column :expires_at, DateTime, null: false
    end
  end
end
