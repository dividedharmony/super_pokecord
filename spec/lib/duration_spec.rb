# frozen_string_literal: true

require_relative '../../lib/duration'

RSpec.describe Duration do
  describe '::hours_in_seconds' do
    subject { described_class.hours_in_seconds(3) }

    it 'returns the number of seonds in the given number of hours' do
      is_expected.to eq(3 * 60 * 60)
    end
  end

  describe '::minutes_in_seconds' do
    subject { described_class.minutes_in_seconds(7) }

    it 'returns the number of seonds in the given number of hours' do
      is_expected.to eq(7 * 60)
    end
  end

  describe '::countdown_string' do
    let(:future_time) { Time.now + (5 * 60 * 60) + (27 * 60) + 13 }

    subject { described_class.countdown_string(future_time) }

    around do |example|
      Timecop.freeze(Time.now) do
        example.run
      end
    end

    it { is_expected.to eq('5h 27m 13s') }
  end
end
