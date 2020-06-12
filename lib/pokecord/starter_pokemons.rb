# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'

module Pokecord
  class StarterPokemons
    def initialize
      @poke_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def to_h
      starters_by_region.transform_values do |poke_ids|
        poke_ids.map do |poke_id|
          poke_repo.pokemons.where(pokedex_number: poke_id).one!
        end
      end
    end

    private

    attr_reader :poke_repo

    def starters_by_region
      {
        'Kanto' => [1, 4, 7],
        'Johto' => [152, 155, 158],
        'Hoenn' => [252, 255, 258],
        'Sinnoh' => [387, 390, 393],
        'Unova' => [495, 498, 501],
        'Kalos' => [650, 653, 656],
        'Alola' => [722, 725, 728],
        'Galar' => [810, 813, 816]
      }
    end
  end
end
