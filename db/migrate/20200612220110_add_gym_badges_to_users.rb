# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:users) do
      add_column :gym_badges, Integer, null: false, default: 0
      add_column :elite_four_wins, Integer, null: false, default: 0
      add_column :champion_wins, Integer, null: false, default: 0
    end
  end
end
