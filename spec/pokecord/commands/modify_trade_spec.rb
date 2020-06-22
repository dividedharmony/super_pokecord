# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/modify_trade'

RSpec.describe Pokecord::Commands::ModifyTrade do
  describe '#call' do
    context 'if action is :add' do
      let(:discord_id) { '24680' }
      let(:catch_number) { 999 }

      subject { described_class.new(discord_id, catch_number, action: :add).call }

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
                  catch_number: 999,
                  trade_id: existing_trade_id
                ]
              end

              context 'if spawn already is already part of this trade' do
                let(:existing_trade_id) { trade.id }

                it 'returns a failure monad' do
                  expect { subject }.not_to change {
                    spawn_repo.spawned_pokemons.by_pk(spawn.id).one.trade_id
                  }.from(trade.id)
                  expect(subject).to be_failure
                  expect(subject.failure).to eq(
                    I18n.t('add_to_trade.spawn_has_already_been_added')
                  )
                end
              end

              context 'if spawn is not yet part of this trade' do
                let(:existing_trade_id) { nil }

                it 'adds the spawn to the trade' do
                  expect { subject }.to change {
                    spawn_repo.spawned_pokemons.by_pk(spawn.id).one.trade_id
                  }.from(nil).to(trade.id)
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
    end

    context 'if action is :remove' do
      let(:discord_id) { '24680' }
      let(:catch_number) { 999 }

      subject { described_class.new(discord_id, catch_number, action: :remove).call }

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
            expect(subject.failure).to eq(I18n.t('remove_from_trade.no_such_trade'))
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
              expect(subject.failure).to eq(I18n.t('remove_from_trade.user_2_needs_to_accept'))
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
              expect(subject.failure).to eq(I18n.t('remove_from_trade.cannot_add_after_confirm'))
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
              expect(subject.failure).to eq(I18n.t('remove_from_trade.cannot_add_after_confirm'))
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
                  I18n.t('remove_from_trade.no_such_catch_number', number: 999)
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
                  catch_number: 999,
                  trade_id: existing_trade_id
                ]
              end

              context 'if spawn is not already part of the trade' do
                let(:existing_trade_id) { nil }

                it 'returns a failure monad' do
                  expect { subject }.not_to change {
                    spawn_repo.spawned_pokemons.by_pk(spawn.id).one.trade_id
                  }.from(nil)
                  expect(subject).to be_failure
                  expect(subject.failure).to eq(
                    I18n.t('remove_from_trade.spawn_is_not_part_of_trade', number: 999)
                  )
                end
              end

              context 'if spawn is already part of the trade' do
                let(:existing_trade_id) { trade.id }

                it 'removes the spawn from the trade' do
                  expect { subject }.to change {
                    spawn_repo.spawned_pokemons.by_pk(spawn.id).one.trade_id
                  }.from(trade.id).to(nil)
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
    end
  end
end
