# frozen_string_literal: true

TestingFactory.define(:pokemon) do |factory|
  factory.sequence(:pokedex_number) { |n| n + 1 }
  factory.sequence(:name) { |n| "Charmander ##{n}" }
  factory.base_hp { rand(200) + 10 }
  factory.base_attack { rand(200) + 10 }
  factory.base_defense { rand(200) + 10 }
  factory.base_sp_attack { rand(200) + 10 }
  factory.base_sp_defense { rand(200) + 10 }
  factory.base_speed { rand(200) + 10 }
  factory.created_at { Time.now }
  factory.discarded_at nil
  factory.starter false
  factory.rarity_enum { rand(5) }

  factory.trait :common do |t|
    t.rarity_enum 0
  end

  factory.trait :rare do |t|
    t.rarity_enum 1
  end

  factory.trait :very_rare do |t|
    t.rarity_enum 2
  end

  factory.trait :legendary do |t|
    t.rarity_enum 3
  end

  factory.trait :mythic do |t|
    t.rarity_enum 4
  end
end
