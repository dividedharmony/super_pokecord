# frozen_string_literal: true

require 'dry/monads'

module Pokecord
  class FightUpdater
    include Dry::Monads[:result]

    def initialize(user, fight_event, fight_type)
      @user = user
      @fight_event = fight_event
      @fight_type = fight_type
      @fight_event_repo = Repositories::FightEventRepo.new(
        Db::Connection.registered_container
      )
      @user_repo = Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      update_user
      update_event_cmd = fight_event_repo.fight_events.by_pk(fight_event.id).command(:update)
      update_event_cmd.call(last_fought_at: Time.now, available_at: next_available_at)
      Success(currency_award)
    end

    private

    attr_reader :user, :fight_event, :fight_type, :fight_event_repo, :user_repo

    def update_user
      update_user_cmd = user_repo.users.by_pk(user.id).command(:update)
      user_attr = { current_balance: new_balance }
      case fight_type.code
      when 'gym'
        user_attr[:gym_badges] = user.gym_badges + 1
      when 'elite_four'
        user_attr[:elite_four_wins] = user.elite_four_wins + 1
      when 'champion'
        user_attr[:champion_wins] = user.champion_wins + 1
      else
        # Do nothing
      end
      update_user_cmd.call(user_attr)
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
