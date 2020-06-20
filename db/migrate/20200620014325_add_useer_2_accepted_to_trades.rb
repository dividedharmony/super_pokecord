# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:trades) do
      add_column :user_2_accepted, FalseClass, null: false, default: false
    end
  end
end
