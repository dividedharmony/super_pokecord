# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class Catch
      def initialize(event, name_guess)
        @event = event
        @name_guess = name_guess
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
        @catchable_spawned_pokemon = spawn_repo.catchable_pokemon
      end

      def can_catch?
        !catchable_spawned_pokemon.nil?
      end

      def name_correct?
        catchable_spawned_pokemon.pokemon.name == name_guess
      end

      def catch!
        update_command.call(
          user_id: user.id,
          caught_at: Time.now
        )
      end

      private

      attr_reader :event, :name_guess, :user_repo, :spawn_repo, :catchable_spawned_pokemon

      def user
        @_user ||= begin
          user_repo.users.where(discord_id: event.user.id).one ||
            user_repo.create(discord_id: event.user.id, created_at: Time.now)
        end
      end

      def update_command
        spawn_repo.spawned_pokemons.by_pk(catchable_spawned_pokemon.id).command(:update)
      end
    end
  end
end
