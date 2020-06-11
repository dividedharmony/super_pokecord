# frozen_string_literal: true

require_relative '../../lib/taskers/reset_users_exp_per_step'

RSpec.describe Taskers::ResetUsersExpPerStep do
  describe '#call' do
    let(:user_repo) do
      Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:mock_output) { double('STDOUT') }

    subject { described_class.new(mock_output).call }

    before do
      allow(mock_output).to receive(:puts).with(instance_of(String))
    end

    context 'if user has a non-standard exp_per_step' do
      before do
        TestingFactory[:user, exp_per_step: 42]
      end

      it 'sets the exp_per_step to the standard amount' do
        expect { subject }.to change {
          user_repo.users.first.exp_per_step
        }.from(42).to(50)
      end
    end

    context 'if user has a standard exp_per_step' do
      before do
        TestingFactory[:user, exp_per_step: 50]
      end

      it 'sets the exp_per_step to the standard amount' do
        expect { subject }.not_to change {
          user_repo.users.first.exp_per_step
        }.from(50)
      end
    end
  end
end
