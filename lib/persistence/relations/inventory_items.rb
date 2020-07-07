# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class InventoryItems < ROM::Relation[:sql]
      schema(:inventory_items, infer: true) do
        associations do
          belongs_to :user
          belongs_to :product
        end
      end

      auto_struct(:true)
    end
  end
end
