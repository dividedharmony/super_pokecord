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
end
