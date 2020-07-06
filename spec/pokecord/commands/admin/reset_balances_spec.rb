# frozen_string_literal: true

require_relative '../../../../lib/pokecord/commands/admin/reset_balances'

RSpec.describe Pokecord::Commands::Admin::ResetBalances do
  describe '#call' do
    let(:user_repo) do
      Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:reset_balance) { described_class.new }

    subject { reset_balance.call }

    it 'resets each user.current_balance to zero' do
      user1 = TestingFactory[:user, current_balance: 13_343]
      user2 = TestingFactory[:user, current_balance: 0]
      user3 = TestingFactory[:user, current_balance: 5]
      expect(subject.value!).to eq(I18n.t('admin.reset_balances.success'))
      expect(
        user_repo.users.by_pk(user1.id).one.current_balance
      ).to eq(0)
      expect(
        user_repo.users.by_pk(user2.id).one.current_balance
      ).to eq(0)
      expect(
        user_repo.users.by_pk(user3.id).one.current_balance
      ).to eq(0)
    end
  end
end
