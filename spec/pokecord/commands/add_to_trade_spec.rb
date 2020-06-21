# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/add_to_trade'

RSpec.describe Pokecord::Commands::AddToTrade do
  describe '#call' do
    let(:discord_id) { '24680' }
    let(:catch_number) { 999 }

    subject { described_class.new(discord_id, catch_number).call }

    context 'if no user exists with the given discord_id' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('user_needs_to_start'))
      end
    end

    context 'if a user exists with the given discord_id' do
      let!(:user) { TestingFactory[:user, discord_id: discord_id] }

      context 'if user has no pending_trades' do
        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(I18n.t('add_to_trade.no_such_trade'))
        end
      end

      context 'if user has a pending trade' do
        context 'if trade has not been accepted yet' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: false,
              user_1_id: user.id
            ]
          end

          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(I18n.t('add_to_trade.user_2_needs_to_accept'))
          end
        end

        context 'if user is user_1 and has confirmed the trade' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: true,
              user_1_id: user.id,
              user_1_confirm: true
            ]
          end

          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(I18n.t('add_to_trade.cannot_add_after_confirm'))
          end
        end

        context 'if user is user_2 and has confirmed the trade' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: true,
              user_2_id: user.id,
              user_2_confirm: true
            ]
          end

          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(I18n.t('add_to_trade.cannot_add_after_confirm'))
          end
        end

        context 'if trade is otherwise valid' do
          let!(:trade) do
            TestingFactory[
              :trade,
              user_2_accepted: true,
              user_1_id: user.id,
              user_2_confirm: true
            ]
          end

          context 'if user does not have a spawn with that catch number' do
            it 'returns a failure monad' do
              expect(subject).to be_failure
              expect(subject.failure).to eq(
                I18n.t('add_to_trade.no_such_catch_number', number: 999)
              )
            end
          end

          context 'if user has a spawn with that catch number' do
            let(:spawn_repo) do
              Repositories::SpawnedPokemonRepo.new(
                Db::Connection.registered_container
              )
            end
            let!(:spawn) do
              TestingFactory[
                :spawned_pokemon,
                user_id: user.id,
                catch_number: 999
              ]
            end

            it 'adds the spawn to the trade' do
              expect { subject }.to change {
                spawn_repo.spawned_pokemons.by_pk(spawn.id).one.trade_id
              }.from(nil).to(trade.id)
              expect(subject).to be_success
              expect(subject.value!.id).to eq(trade.id)
            end
          end
        end
      end
    end
  end
end
