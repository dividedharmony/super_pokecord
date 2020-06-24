# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/fight_type_repo'
require_relative '../../repositories/fight_event_repo'
require_relative '../../repositories/user_repo'

require_relative '../../duration'
require_relative '../../readable_number'
require_relative '../fight_conditions'
require_relative '../npc_name'

module Pokecord
  module Commands
    class Fight
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, fight_code)
        @discord_id = discord_id
        @fight_code = fight_code
        @fight_type_repo = Repositories::FightTypeRepo.new(
          Db::Connection.registered_container
        )
        @fight_event_repo = Repositories::FightEventRepo.new(
          Db::Connection.registered_container
        )
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        yield validate_user
        yield validate_pokemon
        yield validate_code
        yield validate_conditions
        yield validate_time

        update_user_cmd = user_repo.users.by_pk(user.id).command(:update)
        update_user_cmd.call(current_balance: new_balance)
        update_event_cmd = fight_event_repo.fight_events.by_pk(fight_event.id).command(:update)
        update_event_cmd.call(last_fought_at: Time.now, available_at: next_available_at)
        name = Pokecord::NpcName.new(fight_type.code, user).to_s
        Success(I18n.t('fight.success', name: name, currency: ReadableNumber.stringify(currency_award)))
      end

      private

      attr_reader :discord_id, :fight_code, :fight_type_repo, :fight_event_repo, :user_repo

      def validate_user
        if user.nil?
          Failure(I18n.t('user_needs_to_start'))
        else
          Success()
        end
      end

      def validate_pokemon
        if user.current_pokemon.nil?
          Failure(I18n.t('needs_a_current_pokemon'))
        else
          Success()
        end
      end

      def validate_code
        if fight_type.nil?
          Failure(I18n.t('fight.incorrect_code'))
        else
          Success()
        end
      end

      def validate_conditions
        conditions = FightConditions.new(user, fight_type)
        if conditions.met?
          Success()
        else
          Failure(conditions.error_message)
        end
      end

      def validate_time
        if fight_event.available_at < Time.now
          Success()
        else
          Failure(
            I18n.t(
              'fight.not_available_yet',
              name: fight_type.code,
              time: Duration.countdown_string(fight_event.available_at)
            )
          )
        end
      end

      def user
        @_user ||= user_repo.
          users.
          combine(:current_pokemon).
          where(discord_id: discord_id).
          one
      end

      def fight_type
        @_fight_type ||= fight_type_repo.fight_types.where(code: fight_code).one
      end

      def fight_event
        @_fight_event ||= begin
          fight_event_repo.fight_events.where(user_id: user.id, fight_type_id: fight_type.id).one ||
            fight_event_repo.create(
              user_id: user.id,
              fight_type_id: fight_type.id,
              created_at: Time.now,
              last_fought_at: Time.now - 1,
              available_at: Time.now - 1
            )
        end
      end

      def new_balance
        user.current_balance + currency_award
      end

      def currency_award
        @_currency_award ||= rand(fight_type.max_reward - fight_type.min_reward) +
          fight_type.min_reward +
          pokemon_award
      end

      def pokemon_award
        rand(user.current_pokemon.level) * fight_type.pokemon_multiplier_reward
      end

      def next_available_at
        Time.now + fight_type.time_delay
      end
    end
  end
end
