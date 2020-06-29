# frozen_string_literal: true

require 'rom-sql'

module Persistence
  module Relations
    class PartyRoles < ROM::Relation[:sql]
      schema(:party_roles, infer: true) do
        associations do
          has_many :users, foreign_key: :primary_role_id, as: :primary_users
          has_many :users, foreign_key: :secondary_role_id, as: :secondary_users
        end
      end

      auto_struct(:true)
    end
  end
end
