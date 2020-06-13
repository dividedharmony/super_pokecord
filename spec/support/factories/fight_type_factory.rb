# frozen_string_literal: true

TestingFactory.define(:fight_type) do |factory|
  factory.code 'rando'
  factory.time_delay 60
  factory.max_reward 500
  factory.min_reward 100
  factory.pokemon_multiplier_reward 1
  factory.created_at { Time.now }

  factory.trait :rival do |t|
    t.code 'rival'
  end

  factory.trait :gym do |t|
    t.code 'gym'
  end

  factory.trait :elite_four do |t|
    t.code 'elite_four'
  end

  factory.trait :champion do |t|
    t.code 'champion'
  end
end
