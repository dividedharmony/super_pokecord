# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class ProductRepo < ROM::Repository[:products]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
