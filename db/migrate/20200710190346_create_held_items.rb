# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table(:held_items) do
      primary_key :id
      foreign_key :spawned_pokemon_id, :spawned_pokemons, null: false, index: true
      foreign_key :product_id, :products, null: false, index: true

      column :created_at, DateTime, null: false
    end
  end
end
