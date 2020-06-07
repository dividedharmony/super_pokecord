# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'
require_relative '../repositories/spawned_pokemon_repo'

module Pokecord
  class WildPokemon
    def initialize
      @poke_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
      @pokedex_number = rand(809) + 1
      @pokemon = poke_repo.pokemons.where(pokedex_number: pokedex_number).one!
    end

    def spawn!
      @spawned_pokemon = spawn_repo.create(
        pokemon_id: pokemon.id,
        created_at: Time.now
      )
    end

    def pic_file
      picture_number = pokedex_number.to_s.rjust(3, '0')
      File.expand_path(
        "../../pokemon_info/images/#{picture_number}.png", File.dirname(__FILE__)
      )
    end

    private

    attr_reader :poke_repo,
                :spawn_repo,
                :pokedex_number,
                :pokemon,
                :spawned_pokemon
  end
end
