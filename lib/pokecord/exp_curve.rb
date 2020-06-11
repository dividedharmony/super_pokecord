# frozen_string_literal: true

module Pokecord
  class ExpCurve
    LOW_LEVELS = (1..15)
    MID_LEVELS = (16..89)
    HIGH_LEVELS = (90..99)
    # important to note for all
    # these curves is that you
    # earn 50 exp per step for
    # every unecumbered step
    EXP_PER_STEP = 50

    def initialize(current_level)
      @current_level = current_level
    end

    def required_exp_for_next_level
      if LOW_LEVELS.include?(current_level)
        low_level_curve
      elsif MID_LEVELS.include?(current_level)
        mid_level_curve
      elsif HIGH_LEVELS.include?(current_level)
        high_level_curve
      else
        0
      end
    end

    private

    attr_reader :current_level

    # at level one: 6 steps to level 2
    # at level 15: 20 steps to level 16
    def low_level_curve
      (current_level + 5) * EXP_PER_STEP
    end

    # at level 16: 21 steps to level 17
    # at level 89: 35 steps to level 90
    def mid_level_curve
      ((current_level / 5) + 18) * EXP_PER_STEP
    end

    # at level 90: 36 steps to level 91
    # at level 99: 45 steps to level 100
    def high_level_curve
      (current_level - 54) * EXP_PER_STEP
    end
  end
end
