# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/trade_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class ModifyTrade
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, catch_number, action: nil)
        @discord_id = discord_id
        @catch_number = catch_number
        @action = action
        @i18n_key = action == :add ? 'add_to_trade' : 'remove_from_trade'
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @trade_repo = Repositories::TradeRepo.new(
          Db::Connection.registered_container
        )
        @spawn_repo = Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        user = yield get_user
        trade = yield get_trade(user)
        yield validate_trade(user, trade)
        spawn = yield get_spawn(user)
        yield validate_spawn(spawn, trade)

        update_cmd = spawn_repo.spawned_pokemons.by_pk(spawn.id).command(:update)
        if action == :add
          update_cmd.call(trade_id: trade.id)
        elsif action == :remove
          update_cmd.call(trade_id: nil)
        else
          raise ArgumentError, 'Only :add and :remove are acceptable actions for this class'
        end
        Success(trade)
      end

      private

      attr_reader :discord_id,
                  :catch_number,
                  :action,
                  :i18n_key,
                  :user_repo,
                  :trade_repo,
                  :spawn_repo

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
          Failure(I18n.t("#{i18n_key}.no_such_trade"))
        else
          Success(trade)
        end
      end

      def validate_trade(user, trade)
        already_confirmed = (trade.user_1_id == user.id && trade.user_1_confirm) ||
          (trade.user_2_id == user.id && trade.user_2_confirm)
        if already_confirmed
          Failure(I18n.t("#{i18n_key}.cannot_add_after_confirm"))
        elsif !trade.user_2_accepted
          Failure(I18n.t("#{i18n_key}.user_2_needs_to_accept"))
        else
          Success()
        end
      end

      def get_spawn(user)
        spawn = spawn_repo.
          spawned_pokemons.
          where(catch_number: catch_number, user_id: user.id).
          one
        if spawn.nil?
          Failure(I18n.t("#{i18n_key}.no_such_catch_number", number: catch_number))
        else
          Success(spawn)
        end
      end

      def validate_spawn(spawn, trade)
        if action == :add && spawn.trade_id == trade.id
          Failure(I18n.t('add_to_trade.spawn_has_already_been_added'))
        elsif action == :remove && spawn.trade_id != trade.id
          Failure(I18n.t('remove_from_trade.spawn_is_not_part_of_trade'))
        else
          Success(spawn)
        end
      end
    end
  end
end
