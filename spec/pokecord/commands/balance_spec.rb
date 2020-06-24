# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/balance'

RSpec.describe Pokecord::Commands::Balance do
  describe '#call' do
    let(:discord_id) { '1234567' }

    subject { described_class.new(discord_id).call }

    context 'if there is no user with that discord_id' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('user_needs_to_start'))
      end
    end

    context 'if there is a user with that discord_id' do
      before do
        TestingFactory[:user, discord_id: '1234567', current_balance: 1234567]
      end

      it 'returns the user.current_balance in human-readable format' do
        expect(subject).to be_success
        expect(subject.value!).to eq('1,234,567')
      end
    end
  end
end
