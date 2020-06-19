# frozen_string_literal: true

TestingFactory.define(:trade) do |factory|
  factory.association(:user_1)
  factory.association(:user_2)
  factory.created_at { Time.now }
  factory.updated_at { Time.now }
  factory.expires_at { Time.now + (60 * 60 * 5) }
end
