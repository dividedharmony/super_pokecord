# frozen_string_literal: true

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

  describe '#get_user' do
    subject { described_class.new('98765').get_user }

    context 'if discord_id does not match an existing user' do
      it 'returns a Failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('user_needs_to_start'))
      end
    end

    context 'if discord_id does match an existing user' do
      let!(:user) { TestingFactory[:user, discord_id: '98765'] }

      it 'returns a Success monad' do
        expect(subject).to be_success
        expect(subject.value!.id).to eq(user.id)
      end
    end
  end

  describe '#get_current_pokemon' do
    let!(:user) { TestingFactory[:user, current_pokemon_id: current_pokemon_id] }
    subject { described_class.new('12345').get_current_pokemon(user) }

    context 'if user.current_pokemon_id is nil' do
      let(:current_pokemon_id) { nil }

      it 'returns a Failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('needs_a_current_pokemon'))
      end
    end

    context 'if user.current_pokemon_id is not nil' do
      let!(:spawn) { TestingFactory[:spawned_pokemon] }
      let!(:user) { TestingFactory[:user, current_pokemon_id: spawn.id] }

      it 'returns a Success monad' do
        expect(subject).to be_success
        expect(subject.value!.id).to eq(spawn.id)
      end
    end
  end

  describe 'subclassing' do
    let(:subclass) do
      Class.new(described_class) do
        def call
          'mock return value'
        end
      end
    end

    subject { subclass.new('12345').call }

    it { is_expected.to eq('mock return value') }
  end
end
