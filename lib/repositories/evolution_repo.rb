# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class EvolutionRepo < ROM::Repository[:evolutions]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
