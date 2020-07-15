# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/hold'

RSpec.describe Pokecord::Commands::Hold do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345', 'Cold Toast') }
  end

  it_behaves_like 'a command that requires a user to have a current_pokemon' do
    let(:command) { described_class.new('12345', 'Cold Toast') }
  end

  it_behaves_like 'an inventory command independent of visibility' do
    before do
      spawn = TestingFactory[:spawned_pokemon]
      TestingFactory[
        :user,
        discord_id: '12345',
        current_pokemon_id: spawn.id
      ]
    end

    let(:command) { described_class.new('12345', 'Cold Toast') }
  end

  describe '#call' do
    let(:pokemon) { TestingFactory[:pokemon, name: 'Apocalypse'] }
    let(:nickname) { nil }
    let!(:spawn) do
      TestingFactory[
        :spawned_pokemon,
        pokemon_id: pokemon.id,
        nickname: nickname
      ]
    end
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: '333444555',
        current_pokemon_id: spawn.id
      ]
    end
    let!(:product) do
      TestingFactory[
        :product,
        name: 'Chicken Biscuits'
      ]
    end

    subject { described_class.new('333444555', 'Chicken Biscuits').call }

    context 'if user has no inventory of product' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(
          I18n.t('hold.insufficient_inventory', product_name: 'Chicken Biscuits')
        )
      end
    end

    context 'if user has an inventory item of product' do
      let!(:inventory_item) do
        TestingFactory[
          :inventory_item,
          product_id: product.id,
          user_id: user.id,
          amount: amount
        ]
      end

      context 'if inventory_item has an amount of zero' do
        let(:amount) { 0 }

        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(
            I18n.t('hold.insufficient_inventory', product_name: 'Chicken Biscuits')
          )
        end
      end

      context 'if inventory_item has an amount of at least one' do
        let(:amount) { 1 }

        context 'if pokemon is already holding an item' do
          before do
            other_product = TestingFactory[
              :product,
              name: 'Orange Soda'
            ]
            TestingFactory[
              :held_item,
              spawned_pokemon_id: spawn.id,
              product_id: other_product.id
            ]
          end

          it 'returns a failure monad' do
            expect(subject).to be_failure
            expect(subject.failure).to eq(
              I18n.t(
                'hold.pokemon_is_already_holding',
                product_name: 'Orange Soda'
              )
            )
          end
        end

        context 'if pokemon is not yet holding an item' do
          context 'if spawn has a nickname' do
            let(:nickname) { 'Jimmy' }

            it 'returns a message wrapped in a success monad' do
              expect { subject }.to change {
                Pokecord::Repos.new.inventory_items.by_pk(inventory_item.id).one.amount
              }.from(1).to(0)
              expect(subject).to be_success
              expect(subject.value!).to eq(
                I18n.t(
                  'hold.success',
                  product_name: 'Chicken Biscuits',
                  pokemon_name: 'Jimmy'
                )
              )
            end
          end

          context 'if spawn does not have a nickname' do
            let(:nickname) { nil }

            it 'returns a message wrapped in a success monad' do
              expect { subject }.to change {
                Pokecord::Repos.new.inventory_items.by_pk(inventory_item.id).one.amount
              }.from(1).to(0)
              expect(subject).to be_success
              expect(subject.value!).to eq(
                I18n.t(
                  'hold.success',
                  product_name: 'Chicken Biscuits',
                  pokemon_name: 'Apocalypse'
                )
              )
            end
          end
        end
      end
    end
  end
end
