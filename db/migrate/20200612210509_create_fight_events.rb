# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :fight_events do
      primary_key :id
      foreign_key :user_id, :users, null: false, index: true
      foreign_key :fight_type_id, :fight_types, null: false, index: true
      column :last_fought_at, DateTime, null: false
      column :available_at, DateTime, null: false
    end
  end
end
