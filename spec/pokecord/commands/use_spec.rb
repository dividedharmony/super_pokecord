# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/use'

RSpec.describe Pokecord::Commands::Use do
  it_behaves_like 'a command that requires a user to have a current_pokemon' do
    let(:command) { described_class.new('12345', 'Salty Rock') }
  end
  it_behaves_like 'an inventory command independent of visibility' do
    let(:command) { described_class.new('12345', 'Salty Rock') }
  end

  describe '#call' do
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: '12345'
      ]
    end
    let!(:product) do
      TestingFactory[
        :product,
        name: 'Salty Rock'
      ]
    end
    let(:use_command) { described_class.new('12345', 'Salty Rock') }

    subject { use_command.call }

    context 'if user does not have an inventory_item of the specified product' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(
          I18n.t('use_item.no_such_item', product_name: 'Salty Rock')
        )
      end
    end

    context 'if user does have an inventory_item of the specified product' do
      let!(:inventory_item) do
        TestingFactory[
          :inventory_item,
          user_id: user.id,
          product_id: product.id,
          amount: amount,
          created_at: Time.now - (24 * 60 * 60),
          updated_at: Time.now - (12 * 60 * 60)
        ]
      end

      context 'if the inventory_item has an amount of zero' do
        let(:amount) { 0 }

        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(
            I18n.t('use_item.no_such_item', product_name: 'Salty Rock')
          )
        end
      end

      context 'if the inventory_item has an amount greater than zero' do
        let(:amount) { 1 }

        context 'if user does not have a current pokemon' do
          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(
              I18n.t('needs_a_current_pokemon')
            )
          end
        end

        context 'if user does have a current pokemon' do
          let(:inventory_repo) do
            Repositories::InventoryItemRepo.new(
              Db::Connection.registered_container
            )
          end
          let!(:evolved_from) { TestingFactory[:pokemon] }
          let!(:spawned_pokemon) do
            TestingFactory[
              :spawned_pokemon,
              pokemon_id: evolved_from.id
            ]
          end
          let!(:user) do
            TestingFactory[
              :user,
              discord_id: '12345',
              current_pokemon_id: spawned_pokemon.id
            ]
          end
          let(:mock_evolve) { instance_double(Pokecord::Evolve) }

          before do
            expect(Pokecord::Evolve).to receive(:new).with(
              having_attributes(id: spawned_pokemon.id),
              :item,
              having_attributes(id: inventory_item.id)
            ) { mock_evolve }
          end

          context 'if evolution is not successful' do
            before do
              expect(mock_evolve).to receive(:call) {
                Dry::Monads::Result::Failure.new('Mock failure')
              }
            end

            it 'returns a failure monad' do
              expect(subject).to be_failure
              expect(subject.failure).to eq(
                I18n.t('use_item.cannot_use_item', product_name: 'Salty Rock')
              )
            end
          end

          context 'if evolution is successful' do
            let!(:evolved_into) { TestingFactory[:pokemon] }
            before do
              expect(mock_evolve).to receive(:call) {
                Dry::Monads::Result::Success.new(evolved_into)
              }
            end

            it 'subtracts the inventory and retuns a success' do
              expect { subject }.to change {
                inventory_repo.inventory_items.by_pk(inventory_item.id).one.updated_at
              }
              reloaded_item = inventory_repo.inventory_items.by_pk(inventory_item.id).one
              expect(reloaded_item.amount).to eq(0)
              expect(subject).to be_success
              payload = subject.value!
              expect(payload.spawned_pokemon.id).to eq(spawned_pokemon.id)
              expect(payload.evolved_from.id).to eq(evolved_from.id)
              expect(payload.evolved_into.id).to eq(evolved_into.id)
            end
          end
        end
      end
    end
  end
end
