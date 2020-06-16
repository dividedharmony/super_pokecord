# frozen_string_literal: true

require 'rom/struct'

module Entities
  class Evolution < ROM::Struct
    TRIGGERS = [
      :level_up,
      :item
    ].freeze

    def triggered_by
      TRIGGERS[trigger_enum]
    end
  end
end
