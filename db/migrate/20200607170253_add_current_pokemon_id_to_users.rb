# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:users) do
      add_foreign_key :current_pokemon_id,
                      :spawned_pokemons,
                      null: true,
                      index: true,
                      foreign_key_constraint_name: :users_current_pokemon_id_fkey
    end
  end
end
