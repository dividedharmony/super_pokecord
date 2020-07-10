# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class HeldItems < ROM::Relation[:sql]
      schema(:held_items, infer: true) do
        associations do
          belongs_to :spawned_pokemon
          belongs_to :product
        end
      end

      auto_struct(:true)
    end
  end
end
