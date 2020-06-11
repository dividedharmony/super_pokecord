# frozen_string_literal: true

require_relative '../../lib/pokecord/exp_curve'

RSpec.describe Pokecord::ExpCurve do
  describe '#required_exp_for_next_level' do
    let(:exp_curve) { described_class.new(current_level) }

    subject { exp_curve.required_exp_for_next_level }

    context 'if current_level is less than 1' do
      let(:current_level) { 0 }

      it { is_expected.to eq(0) }
    end

    context 'if current_level is 1' do
      let(:current_level) { 1 }

      it { is_expected.to eq(300) }
    end

    context 'if current_level is 15' do
      let(:current_level) { 15 }

      it { is_expected.to eq(1_000) }
    end

    context 'if current_level is 16' do
      let(:current_level) { 16 }

      it { is_expected.to eq(1_050) }
    end

    context 'if current_level is 89' do
      let(:current_level) { 89 }

      it { is_expected.to eq(1_750) }
    end

    context 'if current_level is 90' do
      let(:current_level) { 90 }

      it { is_expected.to eq(1_800) }
    end

    context 'if current_level is 99' do
      let(:current_level) { 99 }

      it { is_expected.to eq(2_250) }
    end

    context 'if current_level is greater than 99' do
      let(:current_level) { 100 }

      it { is_expected.to eq(0) }
    end
  end
end
