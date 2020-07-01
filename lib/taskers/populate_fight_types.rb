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
        upsert_fight_type(attributes)
      end
      output.puts "Finished populating fight types!"
    end

    private

    def upsert_fight_type(attributes)
      fight_type = fight_type_repo.fight_types.where(code: attributes[:code]).one
      if fight_type.nil?
        fight_type_repo.create(attributes)
      else
        attributes.delete(:code)
        attributes.delete(:created_at)
        update_cmd = fight_type_repo.fight_types.by_pk(fight_type.id).command(:update)
        update_cmd.call(attributes)
      end
    end

    attr_reader :output, :fight_type_repo, :time_of_creation

    def fight_type_attributes
      [
        {
          code: 'rando',
          time_delay: Duration.minutes_in_seconds(15),
          max_reward: 1200,
          min_reward: 900,
          pokemon_multiplier_reward: 1,
          created_at: time_of_creation
        },
        {
          code: 'rival',
          time_delay: Duration.hours_in_seconds(1),
          max_reward: 3500,
          min_reward: 2500,
          pokemon_multiplier_reward: 5,
          created_at: time_of_creation
        },
        {
          code: 'gym',
          time_delay: Duration.hours_in_seconds(24),
          max_reward: 18_000,
          min_reward: 12_000,
          pokemon_multiplier_reward: 10,
          created_at: time_of_creation
        },
        {
          code: 'elite_four',
          time_delay: Duration.hours_in_seconds(24),
          max_reward: 47_000,
          min_reward: 40_000,
          pokemon_multiplier_reward: 100,
          created_at: time_of_creation
        },
        {
          code: 'champion',
          time_delay: Duration.hours_in_seconds(24),
          max_reward: 180_000,
          min_reward: 140_000,
          pokemon_multiplier_reward: 500,
          created_at: time_of_creation
        }
      ]
    end
  end
end
