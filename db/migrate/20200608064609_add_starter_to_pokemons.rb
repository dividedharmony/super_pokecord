# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:pokemons) do
      add_column :starter, FalseClass, null: false, default: false
    end
  end
end
