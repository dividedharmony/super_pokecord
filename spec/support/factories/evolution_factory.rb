# frozen_string_literal: true

require_relative '../../../lib/entities'

TestingFactory.define(:evolution, struct_namespace: Entities) do |factory|
  factory.association(:evolves_from)
  factory.association(:evolves_into)
  factory.created_at { Time.now }
end
