# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:evolutions) do
      add_foreign_key :product_id, :products, null: true, index: true
    end
  end
end
