# frozen_string_literal: true

require_relative '../../lib/pokecord/random_levels'

RSpec.describe Pokecord::RandomLevels do
  describe '#rand_level' do
    let(:fake_rand_class) do
      Class.new do
        def initialize(first_response, subsequent_response)
          # first response is 0 to 100
          # for precent liklihood of level distribution
          @first_response = first_response
          # second response is the ones digit of the exact level
          @subsequent_response = subsequent_response
          @not_yet_responded = true
        end

        def call(_x)
          if @not_yet_responded
            @not_yet_responded = false
            @first_response
          else
            @subsequent_response
          end
        end
      end
    end

    context 'if a low-low level has been "randomly" selected' do
      let(:rand_proc) { fake_rand_class.new(0, 3) }

      subject { described_class.new(rand_proc).rand_level }

      # ie minimum = 1, plus rand_proc.call(3)
      it { is_expected.to eq(4) }
    end

    context 'if a mid-low level has been "randomly" selected' do
      let(:rand_proc) { fake_rand_class.new(25, 7) }

      subject { described_class.new(rand_proc).rand_level }

      # ie minimum = 11, plus rand_proc.call(7)
      it { is_expected.to eq(18) }
    end

    context 'if a midrange level has been "randomly" selected' do
      let(:rand_proc) { fake_rand_class.new(55, 0) }

      subject { described_class.new(rand_proc).rand_level }

      # ie minimum = 21, plus rand_proc.call(0)
      it { is_expected.to eq(21) }
    end

    context 'if a mid-high level has been "randomly" selected' do
      let(:rand_proc) { fake_rand_class.new(75, 8) }

      subject { described_class.new(rand_proc).rand_level }

      # ie minimum = 31, plus rand_proc.call(8)
      it { is_expected.to eq(39) }
    end

    context 'if a high-high level has been "randomly" selected' do
      let(:rand_proc) { fake_rand_class.new(90, 1) }

      subject { described_class.new(rand_proc).rand_level }

      # ie minimum = 41, plus rand_proc.call(1)
      it { is_expected.to eq(42) }
    end
  end
end