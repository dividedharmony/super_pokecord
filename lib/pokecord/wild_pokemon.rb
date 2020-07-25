# frozen_string_literal: true

require_relative '../entities/pokemon'

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'
require_relative '../repositories/spawned_pokemon_repo'

require_relative './random_levels'
require_relative './exp_curve'
require_relative './rarity'

module Pokecord
  class WildPokemon
    def initialize
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
        level: random_level,
        required_exp: required_exp
      )
    end

    def pic_file
      picture_number = random_pokemon.pokedex_number.to_s.rjust(3, '0')
      File.expand_path(
        "../../pokemon_info/images/#{picture_number}.png", File.dirname(__FILE__)
      )
    end

    private

    attr_reader :rand_proc,
                :poke_repo,
                :spawn_repo,
                :spawned_pokemon

    def random_pokemon
      @_random_pokemon ||=  Pokecord::Rarity.new.random_pokemon
    end

    def random_level
      @_random_level ||= Pokecord::RandomLevels.new.rand_level
    end

    def required_exp
      Pokecord::ExpCurve.new(random_level).required_exp_for_next_level
    end
  end
end
