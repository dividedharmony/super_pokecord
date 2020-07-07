# frozen_string_literal: true

require 'dry/monads/do'
require_relative '../../../lib/pokecord/commands/base_user_command'

RSpec.describe Pokecord::Commands::BaseUserCommand do
  describe '#call' do
    subject { described_class.new('12345').call }

    it 'is an abstract class' do
      expect { subject }.to raise_error(
        NotImplementedError,
        'Pokecord::Commands::BaseUserCommand needs to implment the #call method'
      )
    end
  end

  describe 'subclassing' do
    let(:subclass) do
      Class.new(described_class) do
        include Dry::Monads::Do.for(:call)

        def call
          user = yield get_user
          Success(user)
        end
      end
    end

    subject { subclass.new('12345').call }

    context 'if discord_id does not match an existing user' do
      it 'returns a Failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('user_needs_to_start'))
      end
    end

    context 'if discord_id does match an existing user' do
      let!(:user) { TestingFactory[:user, discord_id: '12345'] }

      it 'returns a Success monad' do
        expect(subject).to be_success
        expect(subject.value!.id).to eq(user.id)
      end
    end
  end
end
