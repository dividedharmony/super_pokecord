# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :pokemons do
      primary_key :id
      column :pokedex_number, Integer, null: false, index: true, unique: true
      column :name, String, null: false, unique: true
      column :base_hp, Integer, null: false, default: 0
      column :base_attack, Integer, null: false, default: 0
      column :base_defense, Integer, null: false, default: 0
      column :base_sp_attack, Integer, null: false, default: 0
      column :base_sp_defense, Integer, null: false, default: 0
      column :base_speed, Integer, null: false, default: 0

      column :created_at, DateTime, null: false
      column :discarded_at, DateTime, null: true
    end
  end
end
