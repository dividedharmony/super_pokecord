# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/buy'

RSpec.describe Pokecord::Commands::Buy do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345', 'XP Booster x12', 12) }
  end

  describe '#call' do
    let(:current_balance) { 1_000_000 }
    let!(:user) { TestingFactory[:user, discord_id: '98765', current_balance: current_balance] }
    let(:purchase_amount) { 1 }
    let(:buy_command) do
      described_class.new(
        '98765',
        'Gas Stone',
        purchase_amount
      )
    end

    subject { buy_command.call }

    context 'if product does not exist' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('buy.no_such_product', product_name: 'Gas Stone'))
      end
    end

    context 'if product does exist' do
      let!(:product) do
        TestingFactory[
          :product,
          name: 'Gas Stone',
          visible: visible,
          price: 500
        ]
      end

      context 'if product is not visible' do
        let(:visible) { false }

        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(I18n.t('buy.no_such_product', product_name: 'Gas Stone'))
        end
      end

      context 'if product is visible' do
        let(:visible) { true }

        context 'if given an invalid amount' do
          let(:purchase_amount) { -9 }

          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(
              I18n.t('buy.amount_must_be_greater_than_zero', amount: -9)
            )
          end
        end

        context 'if given an amount greater than user can purchase' do
          let(:current_balance) { 499 }

          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(
              I18n.t('buy.insufficient_funds', amount: 1, product_name: 'Gas Stone')
            )
          end
        end

        context 'if amount is valid and user can purchase that much' do
          let(:inventory_repo) do
            Repositories::InventoryItemRepo.new(
              Db::Connection.registered_container
            )
          end
          let(:purchase_amount) { 3 }

          context 'if user already has inventory of that product' do
            let!(:inventory_item) do
              TestingFactory[
                :inventory_item,
                user_id: user.id,
                product_id: product.id,
                amount: 13,
                created_at: Time.now - (24 * 60 * 60),
                updated_at: Time.now - (12 * 60 * 60)
              ]
            end

            it 'adds the purchased amount to the inventory_item' do
              expect { subject }.to change {
                inventory_repo.inventory_items.by_pk(inventory_item.id).one.amount
              }.from(13).to(16)
              reloaded_item = inventory_repo.inventory_items.by_pk(inventory_item.id).one
              expect(reloaded_item.user_id).to eq(user.id)
              expect(reloaded_item.product_id).to eq(product.id)
              expect(reloaded_item.created_at).to be_within(5).of(Time.now - (24 * 60 * 60))
              expect(reloaded_item.updated_at).to be_within(5).of(Time.now)
              expect(subject).to be_success
              expect(subject.value!).to eq(
                I18n.t('buy.success', amount: 3, product_name: 'Gas Stone')
              )
            end
          end

          context 'if user does not already have inventory of that product' do
            it 'adds that amount to the inventory of the user' do
              expect { subject }.to change {
                inventory_repo.inventory_items.count
              }.from(0).to(1)
              inventory_item = inventory_repo.inventory_items.first
              expect(inventory_item.amount).to eq(3)
              expect(inventory_item.user_id).to eq(user.id)
              expect(inventory_item.product_id).to eq(product.id)
              expect(inventory_item.created_at).to be_within(5).of(Time.now)
              expect(inventory_item.updated_at).to be_within(5).of(Time.now)
              expect(subject).to be_success
              expect(subject.value!).to eq(
                I18n.t('buy.success', amount: 3, product_name: 'Gas Stone')
              )
            end
          end
        end
      end
    end
  end
end
