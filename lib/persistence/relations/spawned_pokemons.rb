# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class SpawnedPokemons < ROM::Relation[:sql]
      schema(:spawned_pokemons, infer: true) do
        associations do
          belongs_to :pokemon
          belongs_to :user
        end
      end

      auto_struct(:true)
    end
  end
end
