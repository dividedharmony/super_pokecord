# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class FightEvents < ROM::Relation[:sql]
      schema(:fight_events, infer: true) do
        associations do
          belongs_to :fight_type
          belongs_to :user
        end
      end

      auto_struct(:true)
    end
  end
end
