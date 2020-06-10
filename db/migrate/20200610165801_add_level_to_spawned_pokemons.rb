# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:spawned_pokemons) do
      add_column :level, Integer, null: false, default: 0
    end
  end
end
