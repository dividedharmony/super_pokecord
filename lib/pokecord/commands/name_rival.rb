# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'

module Pokecord
  module Commands
    class NameRival
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, rival_name)
        @discord_id = discord_id
        @rival_name = rival_name
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        yield validate_user

        update_cmd = user_repo.users.by_pk(user.id).command(:update)
        update_cmd.call(rival_name: rival_name)
        Success(I18n.t('name_rival.success', name: rival_name))
      end

      private

      attr_reader :discord_id, :rival_name, :user_repo

      def validate_user
        if user.nil?
          Failure(I18n.t('user_needs_to_start'))
        else
          Success()
        end
      end

      def user
        @_user ||= user_repo.
          users.
          where(discord_id: discord_id).
          one
      end
    end
  end
end
