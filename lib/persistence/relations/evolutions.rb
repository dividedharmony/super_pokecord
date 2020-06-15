# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Evolutions < ROM::Relation[:sql]
      schema(:evolutions, infer: true) do
        associations do
          belongs_to :pokemon, foreign_key: :evolves_from_id, as: :evolves_from
          belongs_to :pokemon, foreign_key: :evolves_into_id, as: :evolves_into
        end
      end

      auto_struct(true)
    end
  end
end
