# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:pokemons) do
      add_column :rarity_enum, Integer, null: false, default: 0
    end
  end
end
