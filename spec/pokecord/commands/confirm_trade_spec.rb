# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/confirm_trade'

RSpec.describe Pokecord::Commands::ConfirmTrade do
  describe '#call' do
    let(:trade_repo) do
      Repositories::TradeRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:discord_id) { '123456' }

    subject { described_class.new(discord_id).call }

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
            trade_repo.trades.by_pk(trade.id).one.user_2_confirm
          }.from(false)
          expect(subject).to be_failure
          expect(subject.failure).to eq I18n.t('confirm_trade.no_such_trade')
        end
      end

      context 'if user has one pending trade' do
        context 'if trade has not yet been accepted' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: false,
              user_2_id: user.id,
            ]
          end

          it 'returns a failure monad' do
            expect { subject }.not_to change {
              trade_repo.trades.by_pk(trade.id).one.user_2_confirm
            }.from(false)
            expect(subject).to be_failure
            expect(subject.failure).to eq I18n.t('confirm_trade.user_2_needs_to_accept')
          end
        end

        context 'if trade has already been confirmed by this user' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: true,
              user_2_confirm: true,
              user_2_id: user.id,
            ]
          end

          it 'returns a failure monad' do
            expect { subject }.not_to change {
              trade_repo.trades.by_pk(trade.id).one.user_2_confirm
            }.from(true)
            expect(subject).to be_failure
            expect(subject.failure).to eq I18n.t('confirm_trade.already_confirmed')
          end
        end

        context 'if trade is otherwise valid' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: true,
              user_1_confirm: true,
              user_2_confirm: false,
              user_2_id: user.id,
            ]
          end

          it 'updates the trade to be accepted' do
            expect { subject }.to change {
              trade_repo.trades.by_pk(trade.id).one.user_2_confirm
            }.from(false).to(true)
            expect(subject).to be_success
            returned_trade = subject.value!
            expect(returned_trade.id).to eq(trade.id)
            expect(returned_trade.expires_at).to be_within(5).of(Time.now + (5 * 60))
          end
        end
      end
    end
  end
end
