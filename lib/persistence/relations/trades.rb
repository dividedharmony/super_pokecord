# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Trades < ROM::Relation[:sql]
      schema(:trades, infer: true) do
        associations do
          belongs_to :user, foreign_key: :user_1_id, as: :user_1
          belongs_to :user, foreign_key: :user_2_id, as: :user_2
          has_many :spawned_pokemons
        end
      end

      auto_struct(:true)
    end
  end
end
