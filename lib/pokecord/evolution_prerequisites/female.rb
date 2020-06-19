# frozen_string_literal: true

module Pokecord
  module EvolutionPrerequisites
    class Female
      def self.call(_spawned_pokemon, _evolution)
        # TODO implement a gender system
        # for now, always return true
        true
      end
    end
  end
end
