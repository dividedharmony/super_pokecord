# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Products < ROM::Relation[:sql]
      schema(:products, infer: true)

      auto_struct(true)
    end
  end
end
