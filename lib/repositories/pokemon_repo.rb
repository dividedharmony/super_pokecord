# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class PokemonRepo < ROM::Repository[:pokemons]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
