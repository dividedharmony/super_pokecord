# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/user_repo'
require_relative '../../repositories/trade_repo'
require_relative '../../repositories/spawned_pokemon_repo'

module Pokecord
  module Commands
    class ExecuteTrade
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(trade_id)
        @trade_id = trade_id
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
        spawns = yield validate_spawns

        user_1_spawns, user_2_spawns = spawns.partition do |spawn|
          trade.user_1_id == spawn.user_id
        end

        swap_spawns(user_1_spawns, trade.user_2)
        swap_spawns(user_2_spawns, trade.user_1)

        spawns.each do |spawn|
          handle_current_pokemon(spawn)
          handle_evolution(spawn)
        end

        Success(spawns)
      end

      private

      attr_reader :trade_id, :user_repo, :trade_repo, :spawn_repo

      def trade
        @_trade ||= trade_repo.
          trades.
          combine(:user_1, :user_2, spawned_pokemons: :pokemon).
          by_pk(trade_id).
          one!
      end

      def validate_spawns
        if trade.spawned_pokemons.none?
          Failure(I18n.t('execute_trade.no_spawns_to_trade'))
        else
          Success(trade.spawned_pokemons.to_a)
        end
      end

      def handle_current_pokemon(spawn)
        if trade.user_1.current_pokemon_id == spawn.id
          clear_current_pokemon(trade.user_1)
        elsif trade.user_2.current_pokemon_id == spawn.id
          clear_current_pokemon(trade.user_2)
        end
      end

      def handle_evolution(_spawn)
        # TODO evolve pokemon that evolve from trading
      end

      def clear_current_pokemon(user)
        update_user_cmd = user_repo.users.by_pk(user.id).command(:update)
        update_user_cmd.call(current_pokemon_id: nil)
      end

      def swap_spawns(spawns, new_user)
        catch_max = spawn_repo.max_catch_number(new_user)
        spawns.each do |spawn|
          catch_max += 1
          update_spawn_cmd = spawn_repo.spawned_pokemons.by_pk(spawn.id).command(:update)
          update_spawn_cmd.call(
            user_id: new_user.id,
            catch_number: catch_max,
            trade_id: nil
          )
        end
      end
    end
  end
end
