# frozen_string_literal: true

module Pokecord
  class SpawnRate
    def initialize(min_steps, max_steps)
      @min_steps = min_steps
      @max_steps = max_steps
      @current_steps = 0
      set_requirement!
    end

    def step!
      @current_steps += 1
    end

    def should_spawn?
      current_steps >= max_steps
    end

    def reset!
      @current_steps = 0
      set_requirement!
    end

    private

    def set_requirement!
      @current_requirement = rand(max_steps - min_steps) + min_steps
    end

    attr_reader :min_steps, :max_steps, :current_steps, :current_requirement
  end
end
