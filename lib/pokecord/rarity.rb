# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'

module Pokecord
  class Rarity
    MAXIMUM_RARITY = 1_750
    # From 0 to 1_749, how likely
    # is a random drop to drop a
    # pokemon of this rarity?
    RARITY_LEVELS = {
      common: 0..1_000,
      rare: 1_001..1_638,
      very_rare: 1_639..1_738,
      legendary: 1_739..1_748,
      mythic: 1_749..1_749
    }.freeze

    # Accepts a Proc/lambda for
    # generating random numbers
    def initialize(rand_proc = nil)
      @rand_proc = rand_proc || Proc.new { |x| rand(x) }
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def random_pokemon
      pokemon_repo.
        pokemons.
        where(rarity_enum: random_rarity_enum).
        to_a.
        sample
    end

    private

    attr_reader :pokemon_repo

    def random_rarity_enum
      random_number = rand_proc.call(MAXIMUM_RARITY)
      RARITY_LEVELS.find_index do |_rarity_name, rarity_range|
        rarity_range.include?(random_number)
      end
    end
  end
end
