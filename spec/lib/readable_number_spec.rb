# frozen_string_literal: true

require_relative '../../lib/readable_number'

RSpec.describe ReadableNumber do
  describe '.stringify' do
    context 'if given number has a decimal point' do
      it 'only delimits the number characters before the decimal point' do
        expect(described_class.stringify(1.23456789)).to eq('1.23456789')
        expect(described_class.stringify(12.3456789)).to eq('12.3456789')
        expect(described_class.stringify(123.456789)).to eq('123.456789')
        expect(described_class.stringify(1234.56789)).to eq('1,234.56789')
        expect(described_class.stringify(12345.6789)).to eq('12,345.6789')
        expect(described_class.stringify(123456.789)).to eq('123,456.789')
        expect(described_class.stringify(1234567.89)).to eq('1,234,567.89')
        expect(described_class.stringify(12345678.9)).to eq('12,345,678.9')
      end
    end

    context 'if given number does not have a decimal point' do
      it 'properly inserts commas to make the number human-readable' do
        expect(described_class.stringify(1111111111111111)).to eq('1,111,111,111,111,111')
        expect(described_class.stringify(11111111111111111)).to eq('11,111,111,111,111,111')
        expect(described_class.stringify(111111111111111111)).to eq('111,111,111,111,111,111')
      end
    end
  end
end
