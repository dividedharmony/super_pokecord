# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :evolutions do
      primary_key :id
      foreign_key :evolves_from_id, :pokemons, null: false, index: true
      foreign_key :evolves_into_id, :pokemons, null: false, index: true
      column :trigger_enum, Integer, null: false, default: 0
      column :level_requirement, Integer, null: false, default: 0
      column :prerequisites_enum, Integer, null: true
      column :created_at, DateTime, null: false
    end
  end
end
