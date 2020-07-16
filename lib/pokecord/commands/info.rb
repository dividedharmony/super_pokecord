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
          InfoPayload.new(spawn, spawn.pokemon)
        )
      end
    end
  end
end
