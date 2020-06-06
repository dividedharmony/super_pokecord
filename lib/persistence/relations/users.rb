# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class Users < ROM::Relation[:sql]
      schema(:users, infer: true)
      auto_struct(true)

      def listing
        select(:id, :discord_id, :created_at)
      end
    end
  end
end
