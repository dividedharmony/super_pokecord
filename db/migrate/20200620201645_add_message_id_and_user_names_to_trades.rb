# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:trades) do
      add_column :message_discord_id, String, null: true
      add_column :user_1_name, String, null: true
      add_column :user_2_name, String, null: true
    end
  end
end
