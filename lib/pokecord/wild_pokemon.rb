# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'
require_relative '../repositories/spawned_pokemon_repo'

require_relative './random_levels'

module Pokecord
  class WildPokemon
    def initialize(rand_proc = nil)
      @rand_proc = rand_proc || Proc.new { |x| rand(x) }
      @poke_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def spawn!
      @spawned_pokemon = spawn_repo.create(
        pokemon_id: random_pokemon.id,
        created_at: Time.now,
        level: Pokecord::RandomLevels.new.rand_level
      )
    end

    def pic_file
      picture_number = pokedex_number.to_s.rjust(3, '0')
      File.expand_path(
        "../../pokemon_info/images/#{picture_number}.png", File.dirname(__FILE__)
      )
    end

    private

    attr_reader :rand_proc,
                :poke_repo,
                :spawn_repo,
                :spawned_pokemon

    def pokedex_number
      @_pokedex_number ||= rand_proc.call(809) + 1
    end

    def random_pokemon
      @_random_pokemon ||=  poke_repo.
        pokemons.
        where(pokedex_number: pokedex_number).
        one!
    end
  end
end
