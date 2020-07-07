# frozen_string_literal: true

require 'dry/monads/do'
require_relative '../../../lib/pokecord/commands/base_inventory_command'

RSpec.describe Pokecord::Commands::BaseInventoryCommand do
  describe '#call' do
    subject { described_class.new('12345', 'Mr Potato Head').call }

    it 'is an abstract class' do
      expect { subject }.to raise_error(
        NotImplementedError,
        'Pokecord::Commands::BaseInventoryCommand needs to implment the #call method'
      )
    end
  end

  describe '#get_product' do
    let(:inventory_command) { described_class.new('12345', 'Mr Potato Head') }

    subject { inventory_command.get_product }

    it 'is an abstract class' do
      expect { subject }.to raise_error(
        NotImplementedError,
        'Pokecord::Commands::BaseInventoryCommand needs to implment the #only_visible_products method'
      )
    end
  end

  describe '#find_or_create_inventory_item' do
    let(:inventory_repo) do
      Repositories::InventoryItemRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:user) { TestingFactory[:user] }
    let(:product) { TestingFactory[:product] }
    let(:inventory_command) { described_class.new('12345', 'Mr Potato Head') }

    subject { inventory_command.find_or_create_inventory_item(user, product) }

    context 'if user already has inventory of that product' do
      let!(:inventory_item) do
        TestingFactory[
          :inventory_item,
          user_id: user.id,
          product_id: product.id
        ]
      end

      it 'returns that inventory_item' do
        expect { subject }.not_to change {
          inventory_repo.inventory_items.count
        }.from(1)
        expect(subject.id).to eq(inventory_item.id)
      end
    end

    context 'if user does not yet have inventory of that product' do
      it 'returns a new inventory_item' do
        expect { subject }.to change {
          inventory_repo.inventory_items.count
        }.from(0).to(1)
        expect(subject.user_id).to eq(user.id)
        expect(subject.product_id).to eq(product.id)
        expect(subject.amount).to eq(0)
        expect(subject.created_at).to be_within(5).of(Time.now)
        expect(subject.updated_at).to be_within(5).of(Time.now)
      end
    end
  end

  describe 'subclassing' do
    describe '#call' do
      let(:subclass) do
        Class.new(described_class) do
          def call
            'stubbed value'
          end
        end
      end

      subject { subclass.new('12345', 'Green Stone').call }

      it { is_expected.to eq('stubbed value') }
    end

    describe '#get_product' do
      context 'if subclass only deals with visible products' do
        let(:subclass) do
          Class.new(described_class) do
            def only_visible_products
              true
            end
          end
        end
        let(:inventory_command) { subclass.new('12345', 'Mr Potato Head') }

        subject { inventory_command.get_product }

        context 'if product does not exist' do
          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(I18n.t('inventory.no_such_product', product_name: 'Mr Potato Head'))
          end
        end

        context 'if product does exist' do
          let!(:product) do
            TestingFactory[
              :product,
              name: 'Mr Potato Head',
              visible: visible,
              price: 500
            ]
          end

          context 'if product is not visible' do
            let(:visible) { false }

            it 'returns a failure monad' do
              expect(subject).to be_failure
              expect(subject.failure).to eq(I18n.t('inventory.no_such_product', product_name: 'Mr Potato Head'))
            end
          end

          context 'if product is visible' do
            let(:visible) { true }

            it 'returns the product wrapped in a Success monad' do
              expect(subject).to be_success
              expect(subject.value!.id).to eq(product.id)
            end
          end
        end
      end

      context 'if subclass deals with products of all visibility' do
        let(:subclass) do
          Class.new(described_class) do
            def only_visible_products
              false
            end
          end
        end
        let(:inventory_command) { subclass.new('12345', 'Mr Potato Head') }

        subject { inventory_command.get_product }

        context 'if product does not exist' do
          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(I18n.t('inventory.no_such_product', product_name: 'Mr Potato Head'))
          end
        end

        context 'if product does exist' do
          let!(:product) do
            TestingFactory[
              :product,
              name: 'Mr Potato Head',
              visible: visible,
              price: 500
            ]
          end

          context 'if product is not visible' do
            let(:visible) { false }

            it 'returns a failure monad' do
              expect(subject).to be_success
              expect(subject.value!.id).to eq(product.id)
            end
          end

          context 'if product is visible' do
            let(:visible) { true }

            it 'returns the product wrapped in a Success monad' do
              expect(subject).to be_success
              expect(subject.value!.id).to eq(product.id)
            end
          end
        end
      end
    end
  end
end
