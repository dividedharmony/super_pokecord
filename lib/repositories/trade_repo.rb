# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class TradeRepo < ROM::Repository[:trades]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
