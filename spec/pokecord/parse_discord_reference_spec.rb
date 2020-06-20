# frozen_string_literal: true

require_relative '../../lib/pokecord/parse_discord_reference'

RSpec.describe Pokecord::ParseDiscordReference do
  describe '#call' do
    let(:user_reference) { '' }

    subject { described_class.new(user_reference).call }

    context 'if user_reference has no numbers' do
      let(:user_reference) { 'alex_jones' }

      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq('no_discord_id')
      end
    end

    context 'if user_reference has numbers in it' do
      let(:user_reference) { '<!@123456alex_guy9999>' }

      context 'if no user matches up to those numbers' do
        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq('no_such_user')
        end
      end

      context 'if a user matches up to those numbers' do
        let!(:user) { TestingFactory[:user, discord_id: '123456'] }

        it 'returns a success monad' do
          expect(subject).to be_success
          expect(subject.value!.id).to eq(user.id)
        end
      end
    end
  end
end
