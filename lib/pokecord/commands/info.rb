# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_user_command'

module Pokecord
  module Commands
    class Info < BaseUserCommand
      InfoPayload = Struct.new(:spawned_pokemon, :pokemon)

      include Dry::Monads::Do.for(:call)

      def call
        user = yield get_user
        spawn = yield get_current_pokemon(user)
        Success(
          InfoPayload.new(spawn, get_pokemon(spawn))
        )
      end

      private

      def get_pokemon(spawned_pokemon)
        repos.pokemons.by_pk(spawned_pokemon.pokemon_id).one!
      end
    end
  end
end
