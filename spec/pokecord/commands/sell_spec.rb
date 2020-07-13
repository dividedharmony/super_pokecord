# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/sell'

RSpec.describe Pokecord::Commands::Sell do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345', 'XP Booster x12', 12) }
  end

  it_behaves_like 'an inventory command independent of visibility' do
    let(:command) { described_class.new('12345', 'XP Booster x12', 12) }
  end

  describe '#call' do
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: '13579'
      ]
    end
    let!(:product) do
      TestingFactory[
        :product,
        name: 'Fried Chicken',
        price: 30
      ]
    end

    subject { described_class.new('13579', 'Fried Chicken', 6).call }

    context 'if user has no inventory of that product' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(
          I18n.t(
            'sell.insufficient_inventory',
            sell_amount: 6,
            product_name: 'Fried Chicken'
          )
        )
      end
    end

    context 'if user has inventory of that product' do
      let!(:inventory_item) do
        TestingFactory[
          :inventory_item,
          user_id: user.id,
          product_id: product.id,
          amount: previous_amount
        ]
      end

      context 'if user has inventory less than the amount they would like to sell' do
        let(:previous_amount) { 5 }

        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(
            I18n.t(
              'sell.insufficient_inventory',
              sell_amount: 6,
              product_name: 'Fried Chicken'
            )
          )
        end
      end

      context 'if user has inventory equal to or greater than sell amount' do
        let(:previous_amount) { 6 }

        it 'returns a message wrapped in a success monad' do
          expect(subject).to be_success
          expect(subject.success).to eq(
            I18n.t(
              'sell.success',
              sell_amount: 6,
              product_name: 'Fried Chicken',
              currency_award: 90
            )
          )
        end
      end
    end
  end
end
