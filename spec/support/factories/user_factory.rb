# frozen_string_literal: true

TestingFactory.define(:user) do |factory|
  factory.sequence(:discord_id) { |n| "#{n}12345" }
  factory.created_at { Time.now }
  factory.exp_per_step 50

  factory.trait :with_current_pokemon do |t|
    t.association(:current_pokemon)
  end
end
