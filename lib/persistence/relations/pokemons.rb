# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Pokemons < ROM::Relation[:sql]
      schema(:pokemons, infer: true) do
        associations do
          has_many :spawned_pokemons
          has_many :evolutions, foreign_key: :evolves_from_id, as: :progressive_evolutions
          has_many :evolutions, foreign_key: :evolves_into_id, as: :regressive_evolutions
        end
      end

      auto_struct(:true)
    end
  end
end
