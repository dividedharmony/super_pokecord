# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class FightEventRepo < ROM::Repository[:fight_events]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
