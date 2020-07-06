# frozen_string_literal: true

require 'dry/monads'

require_relative '../../../repositories/user_repo'

module Pokecord
  module Commands
    module Admin
      class ResetBalances
        include Dry::Monads[:result]

        def initialize
          @user_repo = Repositories::UserRepo.new(
            Db::Connection.registered_container
          )
        end

        def call
          user_repo.users.each do |user|
            update_cmd = user_repo.users.by_pk(user.id).command(:update)
            update_cmd.call(current_balance: 0)
          end
          Success(I18n.t('admin.reset_balances.success'))
        end

        private

        attr_reader :user_repo
      end
    end
  end
end
