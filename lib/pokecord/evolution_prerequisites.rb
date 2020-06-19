# frozen_string_literal: true

require_relative './evolution_prerequisites/day'
require_relative './evolution_prerequisites/night'
require_relative './evolution_prerequisites/male'
require_relative './evolution_prerequisites/female'
require_relative './evolution_prerequisites/holding_an_item'

module Pokecord
  module EvolutionPrerequisites
    TYPES_OF_PREREQUISITES = [
      Day,
      Night,
      Male,
      Female,
      HoldingAnItem
    ].freeze
  end
end
