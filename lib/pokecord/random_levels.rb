# frozen_string_literal: true

module Pokecord
  class RandomLevels
    # The keys are the minimum level
    # that can be returned by #rand_level
    # and the values are the liklihood
    # from 0 to 99 of that minimum occuring
    LEVEL_DISTRIBUTION = {
      1 => 0..24,
      11 => 25..54,
      21 => 55..74,
      31 => 75..89,
      41 => 90..99
    }.freeze

    # accepts a Proc/lambda for
    # generating random numbers
    def initialize(rand_proc = nil)
      @rand_proc = rand_proc || Proc.new { |x| rand(x) }
    end

    def rand_level
      random_number = rand_proc.call(100)
      min_level = LEVEL_DISTRIBUTION.detect do |min, dist_range|
        dist_range.include?(random_number)
      end[0]
      exact_level(min_level)
    end

    private

    attr_reader :rand_proc

    def exact_level(min_level)
      min_level + rand_proc.call(9)
    end
  end
end
