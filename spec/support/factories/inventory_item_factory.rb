# frozen_string_literal: true

TestingFactory.define(:inventory_item) do |factory|
  factory.association(:user)
  factory.association(:product)
  factory.created_at { Time.now }
  factory.updated_at { Time.now }
end
