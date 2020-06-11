# frozen_string_literal: true

require_relative '../../lib/taskers/populate_required_exp'

RSpec.describe Taskers::PopulateRequiredExp do
  describe '#call' do
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:mock_output) { double('STDOUT') }
    let(:tasker) { described_class.new(mock_output) }

    subject { tasker.call }

    before do
      allow(mock_output).to receive(:puts).with(instance_of(String))
    end

    context 'if pokemon is level 0' do
      before do
        TestingFactory[:spawned_pokemon, level: 0, required_exp: 0]
      end

      it 'does not change the required_exp' do
        expect { subject }.not_to change {
          spawn_repo.spawned_pokemons.first.required_exp
        }.from(0)
      end
    end

    context 'if pokemon is between level 1 and 99' do
      before do
        TestingFactory[:spawned_pokemon, level: 16, required_exp: 0]
      end

      it 'does not change the required_exp' do
        expect { subject }.to change {
          spawn_repo.spawned_pokemons.first.required_exp
        }.from(0).to(1_050)
      end
    end
  end
end
