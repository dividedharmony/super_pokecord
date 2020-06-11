# frozen_string_literal: true

TestingFactory.define(:spawned_pokemon) do |factory|
  factory.association(:pokemon)
  factory.created_at { Time.now }
  factory.level 10
  factory.current_exp 90
  factory.required_exp 750

  factory.trait :caught do |t|
    t.association(:user)
    t.caught_at { Time.now }
    t.sequence(:catch_number) { |n| n + 1 }
  end
end
