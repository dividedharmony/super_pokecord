# frozen_string_literal: true

require_relative '../../lib/taskers/populate_levels'

RSpec.describe Taskers::PopulateLevels do
  describe '#call' do
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:mock_output) { double('STDOUT') }

    subject { described_class.new(mock_output).call }

    before do
      allow(mock_output).to receive(:puts).with(instance_of(String))
    end

    context 'if the level of a spawn is not zero' do
      let!(:spawn) { TestingFactory[:spawned_pokemon, level: 13] }

      it 'ignores that spawn' do
        expect { subject }.not_to change {
          spawn_repo.spawned_pokemons.where(id: spawn.id).one.level
        }.from(13)
      end
    end

    context 'if the level of a spawn is zero' do
      let!(:spawn) { TestingFactory[:spawned_pokemon, level: 0] }

      before do
        expect_any_instance_of(Pokecord::RandomLevels).to receive(:rand_level) { 42 }
      end

      it 'ignores that spawn' do
        expect { subject }.to change {
          spawn_repo.spawned_pokemons.where(id: spawn.id).one.level
        }.from(0).to(42)
      end
    end
  end
end
