# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'

module Taskers
  class PopulateStarters
    def initialize
      @poke_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      $stdout.puts 'Beginning to populate Pokemon starters...'
      starter_pokemons.each do |poke|
        $stdout.puts "Updating #{poke.name}"
        update_cmd = poke_repo.pokemons.by_pk(poke.id).command(:update)
        update_cmd.call(starter: true)
      end
      $stdout.puts 'Finished populating starter Pokemon!'
    end

    private

    attr_reader :poke_repo

    def starter_pokedex_numbers
      [
        1, 4, 7,       # Kanto
        152, 155, 158, # Johto
        252, 255, 258, # Hoenn
        387, 390, 393, # Sinnoh
        495, 498, 501, # Unova
        650, 653, 656, # Kalos
        722, 725, 728, # Alola
      ]
    end

    def starter_pokemons
      poke_repo.
        pokemons.
        where(pokedex_number: starter_pokedex_numbers).
        to_a
    end
  end
end
