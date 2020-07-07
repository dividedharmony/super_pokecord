# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class InventoryItemRepo < ROM::Repository[:inventory_items]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
