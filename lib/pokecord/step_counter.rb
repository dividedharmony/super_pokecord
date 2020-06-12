# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/user_repo'

require_relative './exp_curve'
require_relative './exp_applier'

module Pokecord
  class StepCounter
    MAX_EXP_PER_STEP = Pokecord::ExpCurve::EXP_PER_STEP
    MIN_EXP_PER_STEP = MAX_EXP_PER_STEP / 2

    def initialize(discord_id)
      @discord_id = discord_id
      @user_repo = Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end

    def step!(previous_discord_id)
      return if user.nil? || user.current_pokemon.nil?
      exp_applier = Pokecord::ExpApplier.new(user.current_pokemon, user.exp_per_step)
      exp_applier.apply!
      update_user_exp_per_step(previous_discord_id)
      exp_applier.payload
    end

    private

    attr_reader :discord_id, :user_repo

    def user
      @_user ||= user_repo.
        users.
        combine(current_pokemon: :pokemon).
        where(discord_id: discord_id).
        one
    end

    def current_step_exp
      @_current_step_exp ||= user.exp_per_step
    end

    def update_user_exp_per_step(previous_discord_id)
      current_step_exp = user.exp_per_step
      if discord_id == previous_discord_id
        decrease_step_exp
      else
        increase_step_exp
      end
    end

    def decrease_step_exp
      return if current_step_exp <= MIN_EXP_PER_STEP
      update_command.call(exp_per_step: (current_step_exp - 1))
    end

    def increase_step_exp
      return if current_step_exp >= MAX_EXP_PER_STEP
      update_command.call(exp_per_step: (current_step_exp + 1))
    end

    def update_command
      user_repo.users.by_pk(user.id).command(:update)
    end
  end
end
