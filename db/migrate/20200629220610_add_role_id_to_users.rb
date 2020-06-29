# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:users) do
      add_foreign_key :primary_role_id, :party_roles, null: true, index: true
      add_foreign_key :secondary_role_id, :party_roles, null: true, index: true
    end
  end
end
