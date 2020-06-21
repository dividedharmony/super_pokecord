# frozen_string_literal: true

module Callbacks
  class UpdateTrade
    def initialize(trade)
      @trade = trade
      @trade_repo = Repositories::TradeRepo.new(
        Db::Connection.registered_container
      )
    end

    def call(**options)
      return if options.empty?
      update_cmd = trade_repo.trades.by_pk(trade.id).command(:update)
      update_cmd.call(options.merge(updated_at: Time.now))
    end

    private

    attr_reader :trade, :trade_repo
  end
end
