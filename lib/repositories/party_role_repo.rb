# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class PartyRoleRepo < ROM::Repository[:party_roles]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
