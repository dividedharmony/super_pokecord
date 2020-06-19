# frozen_string_literal: true

require_relative '../../../lib/pokecord/evolution_prerequisites/female'

RSpec.describe Pokecord::EvolutionPrerequisites::Female do
  describe '.call' do
    let(:spawned_pokemon) { double('spawned_pokemon') }
    let(:evolution) { double('evolution') }

    subject { described_class.call(spawned_pokemon, evolution) }

    # as its currently implemented,
    # this method always returns true
    it { is_expected.to be true }
  end
end
