# frozen_string_literal: true

TestingFactory.define(:product) do |factory|
  factory.sequence(:name) { |n| "#{n}th Stone" }
end
