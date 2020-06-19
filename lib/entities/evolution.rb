# frozen_string_literal: true

require 'rom/struct'
require_relative '../pokecord/evolution_prerequisites'

module Entities
  class Evolution < ROM::Struct
    TRIGGERS = [
      :level_up,
      :item,
      :trade
    ].freeze

    class << self
      def enum_value(trigger_name)
        TRIGGERS.index(trigger_name)
      end
    end

    def triggered_by
      TRIGGERS[trigger_enum]
    end

    def prerequisite
      return nil if prerequisites_enum.nil?
      Pokecord::EvolutionPrerequisites::TYPES_OF_PREREQUISITES[prerequisites_enum]
    end

    def prereq_fulfilled?(spawned_pokemon)
      return true if prerequisite.nil?
      prerequisite.call(spawned_pokemon, self)
    end
  end
end
