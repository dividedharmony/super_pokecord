# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class HeldItemRepo < ROM::Repository[:held_items]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
