# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class SpawnedPokemonRepo < ROM::Repository[:spawned_pokemons]
    commands :create, update: :by_pk, delete: :by_pk

    # only returns last spawned pokemon
    # if that pokemon has not been caught yet
    def catchable_pokemon
      last_pokemon = spawned_pokemons.combine(:pokemon).order { id.desc }.first
      last_pokemon.caught_at.nil? ? last_pokemon : nil
    end
  end
end
