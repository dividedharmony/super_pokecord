# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :fight_types do
      primary_key :id
      column :code, String, null: false, index: true, unique: true
      column :created_at, DateTime, null: false
      column :discarded_at, DateTime, null: true
      column :time_delay, Integer, null: false, default: 0
    end
  end
end
