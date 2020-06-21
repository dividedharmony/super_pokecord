# frozen_string_literal: true

require_relative '../../lib/callbacks/update_trade'

RSpec.describe Callbacks::UpdateTrade do
  describe '#call' do
    let(:trade_repo) do
      Repositories::TradeRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:trade) { TestingFactory[:trade] }
    let(:callback) { described_class.new(trade) }

    context 'if no options are passed to the callback' do
      subject { callback.call }

      it 'does not change the trade' do
        expect { subject }.not_to change {
          trade_repo.trades.by_pk(trade.id).one.updated_at
        }
      end
    end

    context 'if options are passed to the callback' do
      subject do
        callback.call(
          user_1_name: 'Mary',
          user_2_name: 'Jack',
          updated_at: Time.now + (5 * 60)
        )
      end

      it 'updates the given trade record' do
        expect { subject }.to change {
          trade_repo.trades.by_pk(trade.id).one.updated_at
        }
        reloaded_trade = trade_repo.trades.by_pk(trade.id).one
        expect(reloaded_trade.user_1_name).to eq('Mary')
        expect(reloaded_trade.user_2_name).to eq('Jack')
      end
    end
  end
end
