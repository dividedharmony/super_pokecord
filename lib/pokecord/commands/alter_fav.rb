# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_user_command'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class AlterFav < BaseUserCommand
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, catch_number, fav_value)
        @catch_number = catch_number
        @fav_value = fav_value
        super(discord_id)
      end

      def call
        user = yield get_user
        spawn = yield get_spawn(user)

        update_cmd = repos.
          spawned_pokemons.
          by_pk(spawn.id).
          command(:update)
        update_cmd.call(favorite: fav_value)
        success_key = fav_value ? 'alter_fav.add_success' : 'alter_fav.remove_success'
        spawn_name = spawn.nickname.nil? ? spawn.pokemon.name : spawn.nickname
        Success(I18n.t(success_key, spawn_name: spawn_name))
      end

      private

      attr_reader :catch_number, :fav_value

      def get_spawn(user)
        spawned_pokemon = repos.
          spawned_pokemons.
          combine(:pokemon).
          where(
            user_id: user.id,
            catch_number: catch_number
          ).
          first
        if spawned_pokemon.nil?
          Failure(I18n.t('alter_fav.no_pokemon_found'))
        else
          Success(spawned_pokemon)
        end
      end
    end
  end
end
