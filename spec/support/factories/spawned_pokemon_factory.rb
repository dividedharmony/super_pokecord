# frozen_string_literal: true

TestingFactory.define(:spawned_pokemon) do |factory|
  factory.association(:pokemon)
  factory.created_at { Time.now }
end
