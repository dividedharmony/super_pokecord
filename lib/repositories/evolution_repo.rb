# frozen_string_literal: true

require 'rom-repository'
require_relative '../entities/evolution'

module Repositories
  class EvolutionRepo < ROM::Repository[:evolutions]
    commands :create, update: :by_pk, delete: :by_pk

    struct_namespace(Entities)
  end
end
