# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Pokemons < ROM::Relation[:sql]
      schema(:pokemons, infer: true)
      auto_struct(:true)
    end
  end
end
