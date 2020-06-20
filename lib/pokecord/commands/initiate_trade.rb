# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/trade_repo'

require_relative '../parse_discord_reference'
require_relative '../../duration'

module Pokecord
  module Commands
    class InitiateTrade
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      EXPIRATION_TIME_DELAY = (5 * 60)

      def initialize(user_1_discord_id, user_2_reference)
        @user_1_discord_id = user_1_discord_id
        @user_2_reference = user_2_reference
        @user_repo = Repositories::PokemonRepo.new(
          Db::Connection.registered_container
        )
        @trade_repo = Repositories::TradeRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        user_1 = yield get_user_1
        user_2 = yield parse_user_2
        yield validate_no_pending_trades(user_1, user_2)

        trade = trade_repo.create(
          user_1_id: user_1.id,
          user_2_id: user_2.id,
          created_at: Time.now,
          updated_at: Time.now,
          expires_at: (Time.now + EXPIRATION_TIME_DELAY)
        )
        Success(trade)
      end

      private

      attr_reader :user_1_discord_id, :user_2_reference, :user_repo, :trade_repo

      def get_user_1
        user = user_repo.users.where(discord_id: user_1_discord_id).one
        if user.nil?
          Failure(I18n.t('user_needs_to_start'))
        else
          Success(user)
        end
      end

      def parse_user_2
        result = Pokecord::ParseDiscordReference.new(user_2_reference).call
        if result.failure?
          Failure(I18n.t("initiate_trade.#{result.failure}"))
        else
          result
        end
      end

      def validate_no_pending_trades(user_1, user_2)
        user_1_pending = trade_repo.pending_trades(user_1.id).to_a
        user_2_pending = trade_repo.pending_trades(user_2.id).to_a
        if user_1_pending.any?
          pending_trade = user_1_pending.first
          wait_time = Duration.countdown_string(pending_trade.expires_at)
          Failure(I18n.t('initiate_trade.user_1_in_pending_trade', time: wait_time))
        elsif user_2_pending.any?
          pending_trade = user_2_pending.first
          wait_time = Duration.countdown_string(pending_trade.expires_at)
          Failure(I18n.t('initiate_trade.user_2_in_pending_trade', time: wait_time))
        else
          Success()
        end
      end
    end
  end
end
