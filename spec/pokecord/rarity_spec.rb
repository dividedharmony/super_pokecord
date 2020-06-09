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
    context 'if a common pokemon is "randomly" selected' do
      before do
        # TODO create pokemon of common rarity
      end
    end

    context 'if a rare pokemon is "randomly" selected'

    context 'if a very_rare pokemon is "randomly" selected'

    context 'if a legendary pokemon is "randomly" selected'

    context 'if a mythic pokemon is "randomly" selected'
  end
end
