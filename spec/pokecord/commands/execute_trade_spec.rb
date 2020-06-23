# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/execute_trade'

RSpec.describe Pokecord::Commands::ExecuteTrade do
  describe '#call' do
    let(:user_repo) do
      Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:user_1) { TestingFactory[:user] }
    let(:user_2) { TestingFactory[:user] }
    let(:trade) { TestingFactory[:trade, user_1_id: user_1.id, user_2_id: user_2.id] }

    subject { described_class.new(trade.id).call }

    context 'if there are no spawns associated with the trade' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('execute_trade.no_spawns_to_trade'))
      end
    end

    context 'if there are spawns associated with the trade' do
      let!(:spawn_owned_by_1) do
        TestingFactory[
          :spawned_pokemon,
          trade_id: trade.id,
          user_id: user_1.id,
          catch_number: 43
        ]
      end
      let!(:spawn_owned_by_2) do
        TestingFactory[
          :spawned_pokemon,
          trade_id: trade.id,
          user_id: user_2.id,
          catch_number: 22
        ]
      end

      before do
        # spawns that are not part of the trade
        # which is important for catch_number
        TestingFactory[
          :spawned_pokemon,
          user_id: user_1.id,
          catch_number: 42
        ]
        TestingFactory[
          :spawned_pokemon,
          user_id: user_2.id,
          catch_number: 21
        ]
      end

      it 'swaps the spawns' do
        expect(subject).to be_success

        reloaded_spawn_1 = spawn_repo.spawned_pokemons.by_pk(spawn_owned_by_1.id).one!
        expect(reloaded_spawn_1.user_id).to eq(user_2.id)
        expect(reloaded_spawn_1.catch_number).to eq(23)
        expect(reloaded_spawn_1.trade_id).to be_nil

        reloaded_spawn_2 = spawn_repo.spawned_pokemons.by_pk(spawn_owned_by_2.id).one!
        expect(reloaded_spawn_2.user_id).to eq(user_1.id)
        expect(reloaded_spawn_2.catch_number).to eq(43)
        expect(reloaded_spawn_2.trade_id).to be_nil
      end

      context 'if user_1.current_pokemon is traded' do
        before do
          update_user_cmd = user_repo.users.by_pk(user_1.id).command(:update)
          update_user_cmd.call(current_pokemon_id: spawn_owned_by_1.id)
        end

        it 'clears user_1.current_pokemon_id' do
          expect { subject }.to change {
            user_repo.users.by_pk(user_1.id).one.current_pokemon_id
          }.from(spawn_owned_by_1.id).to(nil)
        end
      end

      context 'if user_2.current_pokemon is traded' do
        before do
          update_user_cmd = user_repo.users.by_pk(user_2.id).command(:update)
          update_user_cmd.call(current_pokemon_id: spawn_owned_by_2.id)
        end

        it 'clears user_1.current_pokemon_id' do
          expect { subject }.to change {
            user_repo.users.by_pk(user_2.id).one.current_pokemon_id
          }.from(spawn_owned_by_2.id).to(nil)
        end
      end

      context 'if a pokemon has an evolution triggered by trading' do
        it 'evolves that pokemon'
      end
    end
  end
end
