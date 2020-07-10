# frozen_string_literal: true

require 'dry/monads'

require_relative '../repos'

module Pokecord
  module Commands
    class BaseUserCommand
      include Dry::Monads[:result]

      def initialize(discord_id)
        @discord_id = discord_id
        @repos = Pokecord::Repos.new
      end

      def call
        raise NotImplementedError, "#{self.class.name} needs to implment the #call method"
      end

      def get_user
        user = repos.
          users.
          where(discord_id: discord_id).
          one
        if user.nil?
          Failure(I18n.t('user_needs_to_start'))
        else
          Success(user)
        end
      end

      def get_current_pokemon(user)
        if user.current_pokemon_id.nil?
          return Failure(I18n.t('needs_a_current_pokemon'))
        end

        spawn = repos.
          spawned_pokemons.
          combine(:pokemon).
          where(id: user.current_pokemon_id).
          first
        if spawn.nil?
          Failure(I18n.t('needs_a_current_pokemon'))
        else
          Success(spawn)
        end
      end

      private

      attr_reader :discord_id, :repos
    end
  end
end
