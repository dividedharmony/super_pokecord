# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Products < ROM::Relation[:sql]
      schema(:products, infer: true) do
        associations do
          has_many :evolutions
        end
      end

      auto_struct(true)
    end
  end
end
