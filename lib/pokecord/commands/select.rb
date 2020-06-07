# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class Select
      def initialize(discord_id, catch_number)
        @discord_id = discord_id
        @catch_number = catch_number
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      def valid_number?
        !user.nil? && !spawned_pokemon.nil?
      end

      # updates the user's current_pokemon
      # returns a spawned_pokemon entity for messaging
      def call
        update_cmd = user_repo.users.by_pk(user.id).command(:update)
        update_cmd.call(current_pokemon_id: spawned_pokemon.id)
        spawned_pokemon
      end

      private

      def user
        @_user ||= user_repo.users.where(discord_id: discord_id).one
      end

      def spawned_pokemon
        @_spawned_pokemon ||= spawn_repo.
          spawned_pokemons.
          combine(:pokemon).
          where(user_id: user.id, catch_number: catch_number).
          first
      end

      attr_reader :discord_id, :catch_number, :user_repo, :spawn_repo
    end
  end
end
