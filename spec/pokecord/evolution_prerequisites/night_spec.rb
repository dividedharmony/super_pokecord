# frozen_string_literal: true

require 'time'
require_relative '../../../lib/pokecord/evolution_prerequisites/night'

RSpec.describe Pokecord::EvolutionPrerequisites::Night do
  describe '.call' do
    let(:spawned_pokemon) { double('spawned_pokemon') }
    let(:evolution) { double('evolution') }

    subject { described_class.call(spawned_pokemon, evolution) }

    context 'if called between 7 am and 6:59 pm' do
      around do |example|
        Timecop.freeze(Time.parse('2020-06-19 07:32:01')) do
          example.run
        end
      end

      it { is_expected.to be false }
    end

    context 'if called between 7 pm and 6:59 am' do
      around do |example|
        Timecop.freeze(Time.parse('2020-06-19 19:32:01')) do
          example.run
        end
      end

      it { is_expected.to be true }
    end
  end
end
