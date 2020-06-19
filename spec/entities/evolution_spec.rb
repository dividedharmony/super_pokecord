# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../../lib/repositories/evolution_repo'

RSpec.describe Entities::Evolution do
  let(:evolution_repo) do
    Repositories::EvolutionRepo.new(
      Db::Connection.registered_container
    )
  end

  describe '.enum_value' do
    subject { described_class.enum_value(trigger_name) }

    context 'if trigger_name is :level_up' do
      let(:trigger_name) { :level_up }

      it { is_expected.to eq(0) }
    end

    context 'if trigger_name is :item' do
      let(:trigger_name) { :item }

      it { is_expected.to eq(1) }
    end

    context 'if trigger_name is :level_up' do
      let(:trigger_name) { :trade }

      it { is_expected.to eq(2) }
    end
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

  describe '#prerequisite' do
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

  describe '#prereq_fulfilled?' do
    let!(:evolution) { TestingFactory[:evolution, prerequisites_enum: 1] }
    let!(:evolution_entity) do
      evolution_repo.
        evolutions.
        by_pk(evolution.id).
        one!
    end
    let(:spawned_pokemon) { double('spawned_pokemon') }

    subject { evolution_entity.prereq_fulfilled?(spawned_pokemon) }

    it 'passes the spawned_pokemon to the EvolutionPrerequisites class' do
      expect(Pokecord::EvolutionPrerequisites::Night).
        to receive(:call).with(spawned_pokemon, evolution_entity) { 'return value' }
      expect(subject).to eq('return value')
    end
  end
end
