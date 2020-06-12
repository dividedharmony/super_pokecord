# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class FightTypes < ROM::Relation[:sql]
      schema(:fight_types, infer: true)

      auto_struct(:true)
    end
  end
end
