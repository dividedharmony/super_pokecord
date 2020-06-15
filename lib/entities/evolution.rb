# frozen_string_literal: true

require 'rom/struct'

module Entities
  class Evolution < ROM::Struct
    TRIGGERS = [
      :level_up
    ].freeze

    def triggered_by
      TRIGGERS[trigger_enum]
    end
  end
end
