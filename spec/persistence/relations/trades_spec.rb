# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../../lib/repositories/trade_repo'

RSpec.describe Persistence::Relations::Trades do
  describe 'associations' do
    describe '.user_1' do
      let!(:user) { TestingFactory[:user] }
      let!(:trade) { TestingFactory[:trade, user_1_id: user.id] }
      let(:trade_repo) do
        Repositories::TradeRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        trade_repo.trades.combine(:user_1).first
      end

      it 'relates to a user record' do
        expect(subject.user_1.id).to eq user.id
      end
    end

    describe '.user_2' do
      let!(:user) { TestingFactory[:user] }
      let!(:trade) { TestingFactory[:trade, user_2_id: user.id] }
      let(:trade_repo) do
        Repositories::TradeRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        trade_repo.trades.combine(:user_2).first
      end

      it 'relates to a user record' do
        expect(subject.user_2.id).to eq user.id
      end
    end
  end
end
