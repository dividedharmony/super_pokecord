# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_user_command'

module Pokecord
  module Commands
    class ListPokemons < BaseUserCommand
      ListPayload = Struct.new(:spawned_pokemons, :page_number, :total_pages)
      PER_PAGE = 25

      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, page_offset, only_favorites = false)
        @page_offset = page_offset
        @only_favorites = only_favorites
        super(discord_id)
      end

      def call
        user = yield get_user
        spawns = yield get_spawns(user)

        Success(
          ListPayload.new(
            spawns,
            page_offset + 1,
            total_pages(user)
          )
        )
      end

      private

      attr_reader :page_offset, :only_favorites

      def offset
        offset = page_offset * PER_PAGE
      end

      def get_spawns(user)
        limited_spawns = spawns_by_user(user).
          combine(:pokemon).
          limit(PER_PAGE).
          offset(offset).
          to_a

        if limited_spawns.none?
          fail_message = only_favorites ?
            I18n.t('fav.no_pokemon_found') :
            I18n.t('list_pokemon.no_pokemon_found')
          Failure(fail_message)
        else
          Success(limited_spawns)
        end
      end

      def total_pages(user)
        (spawns_by_user(user).count.to_f / PER_PAGE).ceil
      end

      def spawns_by_user(user)
        only_favorites ?
          repos.spawn_repo.favorited_by(user) :
          repos.spawn_repo.by_user(user)
      end
    end
  end
end
