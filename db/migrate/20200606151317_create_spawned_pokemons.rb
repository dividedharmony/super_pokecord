# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :spawned_pokemons do
      primary_key :id
      foreign_key :pokemon_id, :pokemons, null: false, unique: false, on_delete: :cascade
      foreign_key :user_id, :users, null: true, unique: false, on_delete: :set_null
      column :created_at, DateTime, null: false
      column :caught_at, DateTime, null: true
    end
  end
end
