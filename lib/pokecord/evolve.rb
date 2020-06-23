# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../entities/evolution'

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'
require_relative '../repositories/spawned_pokemon_repo'
require_relative '../repositories/evolution_repo'

module Pokecord
  class Evolve
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    def initialize(spawned_pokemon, trigger_name)
      @spawned_pokemon = spawned_pokemon
      @trigger_name = trigger_name
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @evolution_repo = Repositories::EvolutionRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      evolutions = yield fulfilled_evolutions
      rand_evolution = evolutions.sample
      evolves_into = rand_evolution.evolves_into
      update_cmd = spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).command(:update)
      update_cmd.call(pokemon_id: evolves_into.id)
      Success(evolves_into)
    end

    private

    attr_reader :spawned_pokemon,
                :trigger_name,
                :spawn_repo,
                :pokemon_repo,
                :evolution_repo

    def pokemon
      @_pokemon ||= pokemon_repo.
        pokemons.
        by_pk(spawned_pokemon.pokemon_id).
        one!
    end

    def fulfilled_evolutions
      fulfilled_evos = evolution_repo.
        evolutions_by_trigger(spawned_pokemon, trigger_name).
        combine(:evolves_into).
        to_a.
        select { |evo| evo.prereq_fulfilled?(spawned_pokemon) }

      if fulfilled_evos.any?
        Success(fulfilled_evos)
      else
        Failure()
      end
    end
  end
end
