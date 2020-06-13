# frozen_string_literal: true

TestingFactory.define(:fight_event) do |factory|
  factory.association(:user)
  factory.association(:fight_type)
  factory.last_fought_at { Time.now - (24 * 60 * 60) }
  factory.available_at { Time.now + (24 * 60 * 60) }
end
