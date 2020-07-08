# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_user_command'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class ListPokemons < BaseUserCommand
      ListPayload = Struct.new(:spawned_pokemons, :total_pages)
      PER_PAGE = 25

      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, page_offset)
        @page_offset = page_offset
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
        super(discord_id)
      end

      def call
        user = yield get_user
        spawns = yield get_spawns(user)

        Success(ListPayload.new(spawns, total_pages(user)))
      end

      private

      attr_reader :page_offset, :spawn_repo

      def offset
        offset = page_offset * PER_PAGE
      end

      def get_spawns(user)
        spawned_pokemons = spawn_repo.
          spawned_pokemons.
          combine(:pokemon).
          where(user_id: user.id).
          limit(PER_PAGE).
          offset(offset).
          to_a
        if spawned_pokemons.none?
          Failure(I18n.t('list_pokemon.no_pokemon_found'))
        else
          Success(spawned_pokemons)
        end
      end

      def total_pages(user)
        (spawn_repo.spawned_pokemons.where(user_id: user.id).count.to_f / PER_PAGE).ceil
      end
    end
  end
end
