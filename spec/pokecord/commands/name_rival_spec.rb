# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/name_rival'

RSpec.describe Pokecord::Commands::NameRival do
  describe '#call' do
    let(:user_repo) do
      Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:discord_id) { '9876543' }
    let(:rival_name) { 'Green' }

    subject { described_class.new(discord_id, rival_name).call }

    context 'if no user with that discord_id exists' do
      it 'returns with a failure' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('user_needs_to_start'))
      end
    end

    context 'if a user with that discord_id does exist' do
      let!(:user) { TestingFactory[:user, discord_id: '9876543'] }

      it 'changes the user.rival_name column' do
        expect { subject }.to change {
          user_repo.users.by_pk(user.id).one.rival_name
        }.from(nil).to('Green')
        expect(subject.value!).to eq(I18n.t('name_rival.success', name: 'Green'))
      end
    end
  end
end
