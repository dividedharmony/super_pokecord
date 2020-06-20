# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../db/connection'
require_relative '../repositories/user_repo'

module Pokecord
  class ParseDiscordReference
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    def initialize(user_reference)
      @user_reference = user_reference
      @user_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      discord_id = yield extract_id
      user = user_repo.users.where(discord_id: discord_id).one
      if user.nil?
        Failure('no_such_user')
      else
        Success(user)
      end
    end

    private

    attr_reader :user_reference, :user_repo

    def extract_id
      id_substrings = user_reference.scan(/\d+/)
      if id_substrings.any?
        Success(id_substrings.first)
      else
        Failure('no_discord_id')
      end
    end
  end
end
