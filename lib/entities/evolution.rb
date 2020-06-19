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

    def triggered_by
      TRIGGERS[trigger_enum]
    end

    def prerequisite
      Pokecord::EvolutionPrerequisites::TYPES_OF_PREREQUISITES[prerequisites_enum]
    end
  end
end
