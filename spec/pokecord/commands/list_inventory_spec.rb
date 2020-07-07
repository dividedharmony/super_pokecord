# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/list_inventory'

RSpec.describe Pokecord::Commands::ListInventory do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345') }
  end

  describe '#call' do
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: '12345'
      ]
    end
    let(:list_inventory) { described_class.new('12345') }

    subject { list_inventory.call }

    context 'if user has no inventory items' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('inventory.no_items'))
      end
    end

    context 'if user has inventory items' do
      let!(:product) { TestingFactory[:product, name: 'Cool Beans'] }
      let!(:inventory_item) do
        TestingFactory[
          :inventory_item,
          user_id: user.id,
          product_id: product.id,
          amount: amount
        ]
      end

      context 'if inventory_item has an amount of zero' do
        let(:amount) { 0 }

        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(I18n.t('inventory.no_items'))
        end
      end

      context 'if inventory_item has an amount greater than zero' do
        let(:amount) { 12 }

        it 'returns a success payload' do
          expect(subject).to be_success
          inventory_items = subject.value!
          expect(inventory_items.count).to eq(1)
          expect(inventory_items.first.product.name).to eq('Cool Beans')
        end
      end
    end
  end
end
