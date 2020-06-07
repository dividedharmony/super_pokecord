# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class ListPokemons
      PER_PAGE = 25

      def initialize(discord_id, page_num)
        @page_num = page_num
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
        @user = user_repo.users.where(discord_id: discord_id).one!
      end

      def to_a
        offset = page_num * PER_PAGE
        spawn_repo.
          spawned_pokemons.
          combine(:pokemon).
          where(user_id: user.id).
          limit(PER_PAGE).
          offset(offset).
          to_a
      end

      private

      attr_reader :page_num, :user_repo, :spawn_repo, :user
    end
  end
end
