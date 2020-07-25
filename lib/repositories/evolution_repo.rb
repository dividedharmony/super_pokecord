# frozen_string_literal: true

require 'rom-repository'
require_relative '../entities'

module Repositories
  class EvolutionRepo < ROM::Repository[:evolutions]
    commands :create, update: :by_pk, delete: :by_pk

    struct_namespace(Entities)

    def evolutions_by_trigger(spawned_pokemon, trigger_name)
      spawn_level = spawned_pokemon.level
      evolutions.
        where(
          evolves_from_id: spawned_pokemon.pokemon_id,
          trigger_enum: Entities::Evolution.enum_value(trigger_name)
        ).
        where { level_requirement <= spawn_level }
    end
  end
end
