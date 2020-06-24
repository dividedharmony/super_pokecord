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
        trade_payload = subject.value!
        expect(trade_payload.trade.id).to eq(trade.id)
        expect(trade_payload.evolution_payloads).to be_empty

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
          expect(subject).to be_success
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
          expect(subject).to be_success
        end
      end

      context 'if a pokemon has an evolution triggered by trading' do
        let!(:evolved_from) { TestingFactory[:pokemon] }
        let!(:evolved_into) { TestingFactory[:pokemon] }
        let!(:spawn_owned_by_2) do
          TestingFactory[
            :spawned_pokemon,
            pokemon_id: evolved_from.id,
            trade_id: trade.id,
            user_id: user_2.id,
            catch_number: 22
          ]
        end

        before do
          mock_evolve1 = instance_double(Pokecord::Evolve)
          mock_evolve2 = instance_double(Pokecord::Evolve)
          expect(Pokecord::Evolve).
            to receive(:new).
            with(have_attributes(id: spawn_owned_by_1.id), :trade) { mock_evolve1 }
          expect(Pokecord::Evolve).
            to receive(:new).
            with(have_attributes(id: spawn_owned_by_2.id), :trade) { mock_evolve2 }
          expect(mock_evolve1).
            to receive(:call) { Dry::Monads::Result::Failure.new(nil) }
          expect(mock_evolve2).
            to receive(:call) { Dry::Monads::Result::Success.new(evolved_into) }
        end

        it 'evolves that pokemon' do
          expect(subject).to be_success
          trade_payload = subject.value!
          expect(trade_payload.trade.id).to eq(trade.id)
          expect(trade_payload.evolution_payloads.length).to eq(1)
          evo_payload = trade_payload.evolution_payloads.first
          expect(evo_payload.spawned_pokemon).to have_attributes(id: spawn_owned_by_2.id)
          expect(evo_payload.evolved_from.id).to eq(evolved_from.id)
          expect(evo_payload.evolved_into.id).to eq(evolved_into.id)
        end
      end
    end
  end
end
