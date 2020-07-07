# frozen_string_literal: true

require 'dry/monads'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'

module Pokecord
  module Commands
    class BaseUserCommand
      include Dry::Monads[:result]

      def initialize(discord_id)
        @discord_id = discord_id
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        raise NotImplementedError, "#{self.class.name} needs to implment the #call method"
      end

      private

      attr_reader :discord_id, :user_repo

      def get_user
        user = user_repo.users.where(discord_id: discord_id).one
        if user.nil?
          Failure(I18n.t('user_needs_to_start'))
        else
          Success(user)
        end
      end
    end
  end
end
