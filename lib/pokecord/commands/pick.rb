# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/pokemon_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class Pick
      def initialize(discord_id, pokemon_name)
        @discord_id = discord_id
        @pokemon_name = pokemon_name
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @pokemon_repo = Repositories::PokemonRepo.new(
          Db::Connection.registered_container
        )
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      def already_picked_starter?
        user.starter_picked
      end

      def name_incorrect?
        picked_pokemon.nil?
      end

      def is_not_starter?
        !picked_pokemon.starter
      end

      # Spawns a pokemon, sets to be caught by the user,
      # sets it as their current_pokemon, sets
      # starter_picked to true, and returns picked_pokemon
      def call
        spawned_pokemon = create_spawn
        update_user_command.call(
          starter_picked: true,
          current_pokemon_id: spawned_pokemon.id
        )
        picked_pokemon
      end

      private

      attr_reader :discord_id, :pokemon_name, :user_repo, :pokemon_repo, :spawn_repo

      def user
        @_user ||= begin
          user_repo.users.where(discord_id: discord_id).one ||
            user_repo.create(discord_id: discord_id, created_at: Time.now)
        end
      end

      def picked_pokemon
        @_picked_pokemon ||= pokemon_repo.pokemons.where(name: pokemon_name).first
      end

      def create_spawn
        spawn_repo.create(
          pokemon_id: picked_pokemon.id,
          user_id: user.id,
          created_at: Time.now,
          caught_at: Time.now,
          catch_number: catch_number,
          level: 1
        )
      end

      def update_user_command
        user_repo.users.by_pk(user.id).command(:update)
      end

      def catch_number
        spawn_repo.max_catch_number(user) + 1
      end
    end
  end
end
