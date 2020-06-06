# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users do
      primary_key :id
      column :discord_id, Integer, null: false, index: true, unique: true
      column :created_at, DateTime, null: false
      column :discarded_at, DateTime, null: true
    end
  end
end
