# frozen_string_literal: true

module Pokecord
  module EvolutionPrerequisites
    class Day
      DAYLIGHT_HOURS = 7..17
      def self.call(_spawned_pokemon, _evolution)
        DAYLIGHT_HOURS.include?(Time.now.hour)
      end
    end
  end
end
