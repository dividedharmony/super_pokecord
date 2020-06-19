# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:spawned_pokemons) do
      add_foreign_key :trade_id, :trades, null: true, index: true
    end
  end
end
