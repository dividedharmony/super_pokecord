# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../../lib/repositories/user_repo'

RSpec.describe Persistence::Relations::Users do
  describe 'associations' do
    describe '.initiated_trades' do
      let!(:user) { TestingFactory[:user] }
      let!(:trade) { TestingFactory[:trade, user_1_id: user.id] }
      let(:user_repo) do
        Repositories::TradeRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        user_repo.users.combine(:initiated_trades).first
      end

      it 'relates to a user record' do
        expect(
          subject.initiated_trades.to_a.map(&:id)
        ).to contain_exactly(trade.id)
      end
    end

    describe '.reciprocated_trades' do
      let!(:user) { TestingFactory[:user] }
      let!(:trade) { TestingFactory[:trade, user_2_id: user.id] }
      let(:user_repo) do
        Repositories::TradeRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        user_repo.users.combine(:reciprocated_trades).first
      end

      it 'relates to a user record' do
        expect(
          subject.reciprocated_trades.to_a.map(&:id)
        ).to contain_exactly(trade.id)
      end
    end
  end
end
