# frozen_string_literal: true

require 'rom-repository'

module Repositories
  class TradeRepo < ROM::Repository[:trades]
    commands :create, update: :by_pk, delete: :by_pk

    def pending_trades(user_id)
      trades.
        where {
          (user_1_id.is(user_id) | user_2_id.is(user_id)) &
          (expires_at > Time.now) &
          !(user_1_confirm & user_2_confirm)
        }
    end
  end
end
