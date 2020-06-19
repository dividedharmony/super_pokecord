# frozen_string_literal: true

require_relative '../../lib/repositories/evolution_repo'

RSpec.describe Repositories::EvolutionRepo do
  describe '#level_up_evolutions' do
    let(:evolution_repo) do
      described_class.new(
        Db::Connection.registered_container
      )
    end
    let(:pokemon) { TestingFactory[:pokemon] }
    let(:spawned_pokemon) do
      TestingFactory[
        :spawned_pokemon,
        pokemon_id: pokemon.id,
        level: 12
      ]
    end

    subject { evolution_repo.level_up_evolutions(spawned_pokemon).to_a }

    context 'if evolution does not evolve from spawned_pokemon' do
      let(:other_pokemon) { TestingFactory[:pokemon] }
      let!(:evolution) { TestingFactory[:evolution, evolves_from_id: other_pokemon.id] }

      it { is_expected.to be_empty }
    end

    context 'if evolution does evolve from spawned_pokemon' do
      let(:level_requirement) { 0 }
      let!(:evolution) do
        TestingFactory[
          :evolution,
          evolves_from_id: pokemon.id,
          trigger_enum: trigger_enum,
          level_requirement: level_requirement
        ]
      end

      context 'if evolution is not triggered by leveling up' do
        # 2 = trade trigger
        let(:trigger_enum) { 2 }

        it { is_expected.to be_empty }
      end

      context 'if evolution is triggered by leveling up' do
        # 0 = level_up trigger
        let(:trigger_enum) { 0 }

        context 'if level_requirement is higher than spawned_pokemon.level' do
          let(:level_requirement) { 13 }

          it { is_expected.to be_empty }
        end

        context 'if level_requirement is equal to spawned_pokemon.level' do
          let(:level_requirement) { 12 }

          it 'contains that evolution' do
            expect(subject.length).to eq(1)
            expect(subject.first.id).to eq(evolution.id)
          end
        end

        context 'if level_requirement is lower than spawned_pokemon.level' do
          let(:level_requirement) { 11 }

          it 'contains that evolution' do
            expect(subject.length).to eq(1)
            expect(subject.first.id).to eq(evolution.id)
          end
        end
      end
    end
  end
end