# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/initiate_trade'

RSpec.describe Pokecord::Commands::InitiateTrade do
  describe '#call' do
    let(:user_1_discord_id) { '12345' }
    let(:user_2_reference) { '<!@9876alex>' }
    let(:user_1_name) { 'Sam Johnson' }
    let(:initiate_trade) { described_class.new(user_1_discord_id, user_2_reference, user_1_name) }
    let(:trade_repo) do
      Repositories::TradeRepo.new(
        Db::Connection.registered_container
      )
    end

    subject { initiate_trade.call }

    context 'if no user matches user_1_discord_id' do
      it 'returns a failure monad' do
        expect { subject }.not_to change {
          trade_repo.trades.count
        }.from(0)
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('user_needs_to_start'))
      end
    end

    context 'if a user matches user_1_discord_id' do
      let!(:user_1) { TestingFactory[:user, discord_id: '12345'] }
      let(:mock_ref_parser) { instance_double(Pokecord::ParseDiscordReference) }

      before do
        expect(Pokecord::ParseDiscordReference).
          to receive(:new).with(user_2_reference) { mock_ref_parser }
      end

      context 'if user_2_reference cannot be parsed' do
        before do
          expect(mock_ref_parser).
            to receive(:call) { Dry::Monads::Result::Failure.new('no_such_user') }
        end

        it 'returns a failure monad' do
          expect { subject }.not_to change {
            trade_repo.trades.count
          }.from(0)
          expect(subject).to be_failure
          expect(subject.failure).to eq(I18n.t('initiate_trade.no_such_user'))
        end
      end

      context 'if user_2_reference can be parsed' do
        let!(:user_2) { TestingFactory[:user] }

        before do
          expect(mock_ref_parser).
            to receive(:call) { Dry::Monads::Result::Success.new(user_2) }
        end

        context 'if user_1 and user_2 are the same user' do
          let!(:user_2) { user_1 }

          it 'returns a failure monad' do
            expect { subject }.not_to change {
              trade_repo.trades.count
            }.from(0)
            expect(subject).to be_failure
            expect(subject.failure).to eq(
              I18n.t('initiate_trade.must_be_different_users')
            )
          end
        end

        context 'if user_1 and user_2 are different users' do
          context 'if user_1 has pending trades' do
            let!(:previous_trade) { TestingFactory[:trade, user_1_id: user_1.id] }

            before do
              expect(Duration).
              to receive(:countdown_string).
              with(instance_of(Time)) { '24h 14m 31s' }
            end

            it 'returns a failure monad' do
              expect { subject }.not_to change {
                trade_repo.trades.count
              }.from(1)
              expect(subject).to be_failure
              expect(subject.failure).to eq(
                I18n.t('initiate_trade.user_1_in_pending_trade', time: '24h 14m 31s')
              )
            end
          end

          context 'if user_2 has pending trades' do
            let!(:previous_trade) { TestingFactory[:trade, user_2_id: user_2.id] }

            before do
              expect(Duration).
                to receive(:countdown_string).
                with(instance_of(Time)) { '04h 19m 51s' }
            end

            it 'returns a failure monad' do
              expect { subject }.not_to change {
                trade_repo.trades.count
              }.from(1)
              expect(subject).to be_failure
              expect(subject.failure).to eq(
                I18n.t('initiate_trade.user_2_in_pending_trade', time: '04h 19m 51s')
              )
            end
          end

          context 'if neither user had pending trades' do
            it 'creates a trade and wraps it in a success monad' do
              expect { subject }.to change {
                trade_repo.trades.count
              }.from(0).to(1)
              expect(subject).to be_success
              trade = subject.value!
              expect(trade.user_1_id).to eq(user_1.id)
              expect(trade.user_2_id).to eq(user_2.id)
              expect(trade.user_1_name).to eq('Sam Johnson')
              expect(trade.created_at).to be_within(5).of(Time.now)
              expect(trade.updated_at).to be_within(5).of(Time.now)
              expect(trade.expires_at).to be_within(5).of(Time.now + (5 * 60))
            end
          end
        end
      end
    end
  end
end
