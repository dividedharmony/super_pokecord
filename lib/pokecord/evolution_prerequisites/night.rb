# frozen_string_literal: true

require_relative './day'

module Pokecord
  module EvolutionPrerequisites
    class Night
      def self.call(spawned_pokemon, evolution)
        !Day.call(spawned_pokemon, evolution)
      end
    end
  end
end
