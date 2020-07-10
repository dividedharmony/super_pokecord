# frozen_string_literal: true

TestingFactory.define(:held_item) do |factory|
  factory.association(:spawned_pokemon)
  factory.association(:product)
  factory.created_at { Time.now }
end
