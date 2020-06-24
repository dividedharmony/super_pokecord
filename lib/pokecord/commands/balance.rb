# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'

require_relative '../../readable_number'

module Pokecord
  module Commands
    class Balance
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id)
        @discord_id = discord_id
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        user = yield get_user
        Success(ReadableNumber.stringify(user.current_balance))
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
