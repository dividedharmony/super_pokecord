# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class Nickname
      def initialize(discord_id, nickname)
        @discord_id = discord_id
        @nickname = nickname
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      def no_pokemon_to_name?
        user.nil? || user.current_pokemon.nil?
      end

      def nickname_taken?
        spawn_repo.spawned_pokemons.where(user_id: user.id, nickname: nickname).count > 0
      end

      # updates user's current_pokemon with given nickname
      # returns that current_pokemon
      def call
        update_cmd = spawn_repo.
          spawned_pokemons.
          by_pk(user.current_pokemon.id).
          command(:update)
        update_cmd.call(nickname: nickname)
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
