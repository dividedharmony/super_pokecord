# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:fight_types) do
      add_column :max_reward, Integer, null: false, default: 0
      add_column :min_reward, Integer, null: false, default: 0
      add_column :pokemon_multiplier_reward, Integer, null: false, default: 0
    end
  end
end
