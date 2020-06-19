# frozen_string_literal: true

module Pokecord
  module EvolutionPrerequisites
    class HoldingAnItem
      def self.call(_spawned_pokemon, _evolution)
        # TODO implement a held_item system
        # for now, always return true
        true
      end
    end
  end
end
