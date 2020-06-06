# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class UserRepo < ROM::Repository[:users]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
