# frozen_string_literal: true

require_relative '../../lib/repositories/trade_repo'

RSpec.describe Repositories::TradeRepo do
  describe '#pending_trades' do
    let(:given_user_id) { 999_999_999 }
    let!(:trade) { TestingFactory[:trade] }
    let(:trade_repo) do
      described_class.new(
        Db::Connection.registered_container
      )
    end

    subject { trade_repo.pending_trades(given_user_id).to_a }

    context 'if given user_id matches user_1_id' do
      let(:user_id) { TestingFactory[:user].id }
      let(:given_user_id) { user_id }
      let(:user_1_confirm) { false }
      let(:user_2_confirm) { false }
      let(:expires_at) { Time.now + (60 * 60) }
      let!(:trade) do
        TestingFactory[
          :trade,
          user_1_id: user_id,
          user_1_confirm: user_1_confirm,
          user_2_confirm: user_2_confirm,
          expires_at: expires_at
        ]
      end

      context 'if expires_at is in the future' do
        context 'if user_1 has confirmed' do
          let(:user_1_confirm) { true }

          context 'if user_2 has not confirmed' do
            let(:user_2_confirm) { false }

            it 'contains the trade' do
              expect(subject.map(&:id)).to contain_exactly(trade.id)
            end
          end

          context 'if user_2 has confirmed' do
            let(:user_2_confirm) { true }

            it { is_expected.to be_empty }
          end
        end

        context 'if user_1 has not confirmed' do
          let(:user_1_confirm) { false }

          it 'contains the trade' do
            expect(subject.map(&:id)).to contain_exactly(trade.id)
          end
        end
      end

      context 'if expires_at is in the past' do
        let(:expires_at) { Time.now - (60 * 60) }

        it { is_expected.to be_empty }
      end
    end

    context 'if given user_id matches user_2_id' do
      let(:user_id) { TestingFactory[:user].id }
      let(:given_user_id) { user_id }
      let(:user_1_confirm) { false }
      let(:user_2_confirm) { false }
      let(:expires_at) { Time.now + (60 * 60) }
      let!(:trade) do
        TestingFactory[
          :trade,
          user_2_id: user_id,
          user_1_confirm: user_1_confirm,
          user_2_confirm: user_2_confirm,
          expires_at: expires_at
        ]
      end

      context 'if expires_at is in the future' do
        context 'if user_1 has confirmed' do
          let(:user_1_confirm) { true }

          context 'if user_2 has not confirmed' do
            let(:user_2_confirm) { false }

            it 'contains the trade' do
              expect(subject.map(&:id)).to contain_exactly(trade.id)
            end
          end

          context 'if user_2 has confirmed' do
            let(:user_2_confirm) { true }

            it { is_expected.to be_empty }
          end
        end

        context 'if user_1 has not confirmed' do
          let(:user_1_confirm) { false }

          it 'contains the trade' do
            expect(subject.map(&:id)).to contain_exactly(trade.id)
          end
        end
      end

      context 'if expires_at is in the past' do
        let(:expires_at) { Time.now - (60 * 60) }

        it { is_expected.to be_empty }
      end
    end

    context 'if given user_id does not match either' do
      it { is_expected.to be_empty }
    end
  end
end
