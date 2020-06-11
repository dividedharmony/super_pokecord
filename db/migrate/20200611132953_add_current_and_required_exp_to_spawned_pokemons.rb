# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:spawned_pokemons) do
      add_column :current_exp, Integer, null: false, default: 0
      add_column :required_exp, Integer, null: false, default: 0
    end
  end
end
