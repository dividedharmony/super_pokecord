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

    # returns maximum catch_number
    # within the scope of a given user
    # (returns 0 if no pokemon have been caught by that user)
    def max_catch_number(user)
      spawned_pokemons.where(user_id: user.id).max(:catch_number) || 0
    end
  end
end
