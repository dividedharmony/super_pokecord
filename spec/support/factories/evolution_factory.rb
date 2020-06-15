# frozen_string_literal: true

TestingFactory.define(:evolution) do |factory|
  factory.association(:evolves_from)
  factory.association(:evolves_into)
  factory.created_at { Time.now }
end
