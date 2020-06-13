# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/fight_type_repo'

require_relative '../duration'

module Taskers
  class PopulateFightTypes
    def initialize(output = nil)
      @output = output || $stdout
      @fight_type_repo = Repositories::FightTypeRepo.new(
        Db::Connection.registered_container
      )
      @time_of_creation = Time.now
    end

    def call
      output.puts "Beginning to populate fight types..."
      fight_type_attributes.each do |attributes|
        output.puts "Creating #{attributes[:code]} fight type"
        fight_type_repo.create(attributes)
      end
      output.puts "Finished populating fight types!"
    end

    private

    attr_reader :output, :fight_type_repo, :time_of_creation

    def fight_type_attributes
      [
        {
          code: 'rando',
          time_delay: Duration.minutes_in_seconds(15),
          max_reward: 1000,
          min_reward: 10,
          pokemon_multiplier_reward: 1,
          created_at: time_of_creation
        },
        {
          code: 'rival',
          time_delay: Duration.hours_in_seconds(1),
          max_reward: 2000,
          min_reward: 500,
          pokemon_multiplier_reward: 5,
          created_at: time_of_creation
        },
        {
          code: 'gym',
          time_delay: Duration.hours_in_seconds(24),
          max_reward: 15_000,
          min_reward: 5_000,
          pokemon_multiplier_reward: 10,
          created_at: time_of_creation
        },
        {
          code: 'elite_four',
          time_delay: Duration.hours_in_seconds(24),
          max_reward: 45_000,
          min_reward: 35_000,
          pokemon_multiplier_reward: 100,
          created_at: time_of_creation
        },
        {
          code: 'champion',
          time_delay: Duration.hours_in_seconds(24),
          max_reward: 180_000,
          min_reward: 120_000,
          pokemon_multiplier_reward: 500,
          created_at: time_of_creation
        }
      ]
    end
  end
end
