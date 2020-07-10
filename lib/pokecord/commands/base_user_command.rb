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

      private

      attr_reader :discord_id, :repos

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
    end
  end
end
