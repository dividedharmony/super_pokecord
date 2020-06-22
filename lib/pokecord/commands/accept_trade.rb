# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/trade_repo'

module Pokecord
  module Commands
    class AcceptTrade
      EXPIRATION_TIME_INCREASE = (5 * 60)

      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, user_2_name)
        @discord_id = discord_id
        @user_2_name = user_2_name
        @user_repo = Repositories::PokemonRepo.new(
          Db::Connection.registered_container
        )
        @trade_repo = Repositories::TradeRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        user = yield get_user
        trade = yield get_trade(user)
        yield validate_trade(user, trade)

        update_cmd = trade_repo.trades.by_pk(trade.id).command(:update)
        trade = update_cmd.call(
          user_2_accepted: true,
          user_2_name: user_2_name,
          updated_at: Time.now,
          expires_at: (Time.now + EXPIRATION_TIME_INCREASE)
        )
        Success(trade)
      end

      private

      attr_reader :discord_id, :user_2_name, :user_repo, :trade_repo

      def get_user
        user = user_repo.users.where(discord_id: discord_id).one
        if user.nil?
          Failure(I18n.t('user_needs_to_start'))
        else
          Success(user)
        end
      end

      def get_trade(user)
        trade = trade_repo.pending_trades(user.id).first
        if trade.nil?
          Failure(I18n.t('accept_trade.no_such_trade'))
        else
          Success(trade)
        end
      end

      def validate_trade(user, trade)
        if trade.user_1_id == user.id
          Failure(I18n.t('accept_trade.only_user_2_can_accept'))
        elsif trade.user_2_accepted
          Failure(I18n.t('accept_trade.already_accepted'))
        else
          Success(trade)
        end
      end
    end
  end
end
