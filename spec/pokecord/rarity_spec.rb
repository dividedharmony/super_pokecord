# frozen_string_literal: true

require_relative '../../lib/pokecord/rarity'

RSpec.describe Pokecord::Rarity do
  describe 'MAXIMUM_RARITY' do
    subject { described_class::MAXIMUM_RARITY }

    it { is_expected.to eq 1_750 }
  end

  describe 'RARITY_LEVELS' do
    subject { described_class::RARITY_LEVELS }

    it 'has value ranges that span from 0 to MAXIMUM_RARITY - 1' do
      (0...1_750).to_a.each do |num|
        rarity_index = subject.find_index do |_rarity_name, rarity_range|
          rarity_range.include?(num)
        end
        expect(rarity_index).not_to be_nil
      end
    end

    it 'has keys of all the different rarities in order of least rare to most' do
      expect(subject.keys[0]).to eq :common
      expect(subject.keys[1]).to eq :rare
      expect(subject.keys[2]).to eq :very_rare
      expect(subject.keys[3]).to eq :legendary
      expect(subject.keys[4]).to eq :mythic
    end
  end

  describe '#random_pokemon' do
    subject do
      described_class.new(not_random_proc).random_pokemon
    end

    context 'if a common pokemon is "randomly" selected' do
      let(:not_random_proc) do
        Proc.new { |_| 0 }
      end
      let!(:common_pokemon) { TestingFactory[:pokemon, :common] }
      let!(:mythic_pokemon) { TestingFactory[:pokemon, :mythic] }

      it 'returns a common pokemon' do
        expect(subject.id).to eq(common_pokemon.id)
      end
    end

    context 'if a rare pokemon is "randomly" selected' do
      let(:not_random_proc) do
        Proc.new { |_| 1_001 }
      end
      let!(:rare_pokemon) { TestingFactory[:pokemon, :rare] }
      let!(:mythic_pokemon) { TestingFactory[:pokemon, :mythic] }

      it 'returns a rare pokemon' do
        expect(subject.id).to eq(rare_pokemon.id)
      end
    end

    context 'if a very_rare pokemon is "randomly" selected' do
      let(:not_random_proc) do
        Proc.new { |_| 1_639 }
      end
      let!(:very_rare_pokemon) { TestingFactory[:pokemon, :very_rare] }
      let!(:mythic_pokemon) { TestingFactory[:pokemon, :mythic] }

      it 'returns a very_rare pokemon' do
        expect(subject.id).to eq(very_rare_pokemon.id)
      end
    end

    context 'if a legendary pokemon is "randomly" selected' do
      let(:not_random_proc) do
        Proc.new { |_| 1_739 }
      end
      let!(:legendary_pokemon) { TestingFactory[:pokemon, :legendary] }
      let!(:mythic_pokemon) { TestingFactory[:pokemon, :mythic] }

      it 'returns a legendary pokemon' do
        expect(subject.id).to eq(legendary_pokemon.id)
      end
    end

    context 'if a mythic pokemon is "randomly" selected' do
      let(:not_random_proc) do
        Proc.new { |_| 1_749 }
      end
      let!(:common_pokemon) { TestingFactory[:pokemon, :common] }
      let!(:mythic_pokemon) { TestingFactory[:pokemon, :mythic] }

      it 'returns a mythic pokemon' do
        expect(subject.id).to eq(mythic_pokemon.id)
      end
    end
  end
end
