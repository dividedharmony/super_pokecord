# frozen_string_literal: true

RSpec.shared_examples 'a user command' do
  # let(:command) { instance of command being tested }

  context 'if user with given discord_id does not exist' do
    it 'requires user to have started to use this command' do
      result = command.call
      expect(result).to be_failure
      expect(result.failure).to eq(I18n.t('user_needs_to_start'))
    end
  end

  context 'if user with given discord_id does exist' do
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: command.send(:discord_id)
      ]
    end

    it 'does not require user to have been started' do
      result = command.call
      if result.success?
        expect(result).to be_success
      else
        expect(result.failure).not_to eq(I18n.t('user_needs_to_start'))
      end
    end
  end
end
