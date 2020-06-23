# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/spawned_pokemon_repo'

require_relative './exp_curve'
require_relative './evolve'

module Pokecord
  class ExpApplier
    LevelUpPayload = Struct.new(:spawned_pokemon, :level, :initial_pokemon, :evolved_into)

    def initialize(spawned_pokemon, incoming_exp)
      @spawned_pokemon = spawned_pokemon
      @initial_pokemon = spawned_pokemon.pokemon
      @incoming_exp = incoming_exp
      @current_level = spawned_pokemon.level
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
      @leveled_up = false
      @evolved_into = nil
    end

    def apply!
      return if current_level < 1 || current_level >= 100
      total_exp = spawned_pokemon.current_exp + incoming_exp
      if total_exp >= spawned_pokemon.required_exp
        @leveled_up = true
        @current_level += 1
        new_total_exp = total_exp - spawned_pokemon.required_exp
        new_required_exp = Pokecord::ExpCurve.new(@current_level).required_exp_for_next_level
        @spawned_pokemon = update_command.call(
          level: current_level,
          current_exp: new_total_exp,
          required_exp: new_required_exp
        )
        evolve_result = Pokecord::Evolve.new(spawned_pokemon, :level_up).call
        evolve_result.fmap do |resulting_pokemon|
          @evolved_into = resulting_pokemon
        end
      else
        update_command.call(current_exp: total_exp)
      end
    end

    def payload
      return nil unless leveled_up
      LevelUpPayload.new(reloaded_spawn, current_level, initial_pokemon, evolved_into)
    end

    private

    attr_reader :spawned_pokemon,
                :initial_pokemon,
                :incoming_exp,
                :spawn_repo,
                :current_level,
                :leveled_up,
                :evolved_into

    def update_command
      spawn_repo.
        spawned_pokemons.
        by_pk(spawned_pokemon.id).
        command(:update)
    end

    def reloaded_spawn
      spawn_repo.
        spawned_pokemons.
        combine(:pokemon).
        where(id: spawned_pokemon.id).
        one!
    end
  end
end
