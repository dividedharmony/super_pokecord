# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/accept_trade'

RSpec.describe Pokecord::Commands::AcceptTrade do
  describe '#call' do
    let(:trade_repo) do
      Repositories::TradeRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:discord_id) { '123456' }
    let(:user_2_name) { 'Judge Dread' }

    subject { described_class.new(discord_id, user_2_name).call }

    context 'if no user exists with that discord_id' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq I18n.t('user_needs_to_start')
      end
    end

    context 'if a user exists with that discord_id' do
      let!(:user) { TestingFactory[:user, discord_id: '123456'] }

      context 'if user has no pending trades' do
        let!(:trade) do
          TestingFactory[
            :trade,
            user_2_accepted: false,
            user_2_id: user.id,
            expires_at: Time.now - (5 * 60)
          ]
        end

        it 'returns a failure monad' do
          expect { subject }.not_to change {
            trade_repo.trades.by_pk(trade.id).one.user_2_accepted
          }.from(false)
          expect(subject).to be_failure
          expect(subject.failure).to eq I18n.t('accept_trade.no_such_trade')
        end
      end

      context 'if user has one pending trade' do
        context 'if user is the user_1 of the trade' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: false,
              user_1_id: user.id,
            ]
          end

          it 'returns a failure monad' do
            expect { subject }.not_to change {
              trade_repo.trades.by_pk(trade.id).one.user_2_accepted
            }.from(false)
            expect(subject).to be_failure
            expect(subject.failure).to eq I18n.t('accept_trade.only_user_2_can_accept')
          end
        end

        context 'if trade has already been accepted' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: true,
              user_2_id: user.id,
            ]
          end

          it 'returns a failure monad' do
            expect { subject }.not_to change {
              trade_repo.trades.by_pk(trade.id).one.user_2_accepted
            }.from(true)
            expect(subject).to be_failure
            expect(subject.failure).to eq I18n.t('accept_trade.already_accepted')
          end
        end

        context 'if trade is otherwise valid' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_id: user.id,
            ]
          end

          it 'updates the trade to be accepted' do
            expect { subject }.to change {
              trade_repo.trades.by_pk(trade.id).one.user_2_accepted
            }.from(false).to(true)
            expect(subject).to be_success
            returned_trade = subject.value!
            expect(returned_trade.id).to eq(trade.id)
            expect(returned_trade.user_2_name).to eq('Judge Dread')
          end
        end
      end
    end
  end
end
