# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/trade_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class AddToTrade
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, catch_number)
        @discord_id = discord_id
        @catch_number = catch_number
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

        update_cmd = spawn_repo.spawned_pokemons.by_pk(spawn.id).command(:update)
        update_cmd.call(trade_id: trade.id)
        Success(trade)
      end

      private

      attr_reader :discord_id, :catch_number, :user_repo, :trade_repo, :spawn_repo

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
          Failure(I18n.t('add_to_trade.no_such_trade'))
        else
          Success(trade)
        end
      end

      def validate_trade(user, trade)
        already_confirmed = (trade.user_1_id == user.id && trade.user_1_confirm) ||
          (trade.user_2_id == user.id && trade.user_2_confirm)
        if already_confirmed
          Failure(I18n.t('add_to_trade.cannot_add_after_confirm'))
        elsif !trade.user_2_accepted
          Failure(I18n.t('add_to_trade.user_2_needs_to_accept'))
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
          Failure(I18n.t('add_to_trade.no_such_catch_number', number: catch_number))
        else
          Success(spawn)
        end
      end
    end
  end
end
