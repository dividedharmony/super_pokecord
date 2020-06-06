# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class SpawnedPokemonRepo < ROM::Repository[:spawned_pokemons]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
