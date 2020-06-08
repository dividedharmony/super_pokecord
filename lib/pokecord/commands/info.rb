# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class Info
      def initialize(discord_id)
        @discord_id = discord_id
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        user&.current_pokemon
      end

      private

      attr_reader :discord_id, :nickname, :user_repo, :spawn_repo

      def user
        @_user ||= user_repo.
          users.
          combine(current_pokemon: :pokemon).
          where(discord_id: discord_id).
          one
      end
    end
  end
end
