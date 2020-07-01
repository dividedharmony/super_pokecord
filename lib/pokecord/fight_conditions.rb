# frozen_string_literal: true

module Pokecord
  class FightConditions
    BADGES_PER_GYM_CYCLE = 8
    ELITE_FOUR_WINS_PER_CHAMPION = 4

    def initialize(user, fight_type)
      @user = user
      @fight_type = fight_type
      @error_message = nil
    end

    def met?
      case fight_type.code
      when 'gym'
        gym_condition_met?
      when 'elite_four'
        elite_four_condition_met?
      when 'champion'
        champion_condition_met?
      else
        true
      end
    end

    attr_reader :error_message

    private

    attr_reader :user, :fight_type

    def gym_condition_met?
      if gym_cycles > elite_four_cycles
        @error_message = 'You must defeat the elite four before you can challenge any more gyms.'
        false
      elsif gym_cycles > user.champion_wins
        @error_message = 'You must defeat the Pokemon Champion before you can challenge any more gyms.'
        false
      else
        true
      end
    end

    def elite_four_condition_met?
      if gym_cycles <= elite_four_cycles
        badges_needed = BADGES_PER_GYM_CYCLE - (user.gym_badges % BADGES_PER_GYM_CYCLE)
        badge_noun = badges_needed == 1 ? 'badge' : 'badges'
        @error_message = "You must collect #{BADGES_PER_GYM_CYCLE} badges before you can challenge the Elite Four. You have **#{badges_needed}** #{badge_noun} left."
        false
      elsif elite_four_cycles > user.champion_wins
        @error_message = "You have already beaten the Elite Four! Challenge the Pokemon Champion next!"
        false
      else
        true
      end
    end

    def champion_condition_met?
      if gym_cycles <= user.champion_wins
        @error_message = "You must collect #{BADGES_PER_GYM_CYCLE} gym badges and defeat the Elite Four before you can challenge the Pokemon Champion."
        false
      elsif elite_four_cycles <= user.champion_wins
        @error_message = "You must defeat the Elite Four before you can challenge the Pokemon Champion."
        false
      else
        true
      end
    end

    def gym_cycles
      @_gym_cycles ||= user.gym_badges / BADGES_PER_GYM_CYCLE
    end

    def elite_four_cycles
      @_elite_four_cycles ||= user.elite_four_wins / ELITE_FOUR_WINS_PER_CHAMPION
    end
  end
end
