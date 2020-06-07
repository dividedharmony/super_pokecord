# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:spawned_pokemons) do
      add_column :nickname, String, null: true
    end
  end
end
