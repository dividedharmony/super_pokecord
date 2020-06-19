# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../../lib/repositories/evolution_repo'

RSpec.describe Entities::Evolution do
  let(:evolution_repo) do
    Repositories::EvolutionRepo.new(
      Db::Connection.registered_container
    )
  end

  describe '#triggered_by' do
    let!(:evolution_entity) do
      evolution_repo.
        evolutions.
        by_pk(evolution.id).
        one!
    end

    subject { evolution_entity.triggered_by }

    context 'if trigger_enum is 0' do
      let!(:evolution) { TestingFactory[:evolution, trigger_enum: 0] }

      it { is_expected.to eq(:level_up) }
    end

    context 'if trigger_enum is 1' do
      let!(:evolution) { TestingFactory[:evolution, trigger_enum: 1] }

      it { is_expected.to eq(:item) }
    end

    context 'if trigger_enum is 2' do
      let!(:evolution) { TestingFactory[:evolution, trigger_enum: 2] }

      it { is_expected.to eq(:trade) }
    end
  end

  describe 'prerequisite' do
    let!(:evolution_entity) do
      evolution_repo.
        evolutions.
        by_pk(evolution.id).
        one!
    end

    subject { evolution_entity.prerequisite }

    context 'if prerequisites_enum is 0' do
      let!(:evolution) { TestingFactory[:evolution, prerequisites_enum: 0] }

      it { is_expected.to eq(Pokecord::EvolutionPrerequisites::Day) }
    end

    context 'if prerequisites_enum is 1' do
      let!(:evolution) { TestingFactory[:evolution, prerequisites_enum: 1] }

      it { is_expected.to eq(Pokecord::EvolutionPrerequisites::Night) }
    end

    context 'if prerequisites_enum is 2' do
      let!(:evolution) { TestingFactory[:evolution, prerequisites_enum: 2] }

      it { is_expected.to eq(Pokecord::EvolutionPrerequisites::Male) }
    end

    context 'if prerequisites_enum is 3' do
      let!(:evolution) { TestingFactory[:evolution, prerequisites_enum: 3] }

      it { is_expected.to eq(Pokecord::EvolutionPrerequisites::Female) }
    end

    context 'if prerequisites_enum is 4' do
      let!(:evolution) { TestingFactory[:evolution, prerequisites_enum: 4] }

      it { is_expected.to eq(Pokecord::EvolutionPrerequisites::HoldingAnItem) }
    end
  end
end
