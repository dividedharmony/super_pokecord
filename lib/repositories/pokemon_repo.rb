# frozen_string_literal: true

require 'rom-repository'
require_relative '../entities'

module Repositories
  class PokemonRepo < ROM::Repository[:pokemons]
    commands :create, update: :by_pk, delete: :by_pk

    struct_namespace(Entities)
  end
end
