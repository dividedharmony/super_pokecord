# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/take'

RSpec.describe Pokecord::Commands::Take do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345') }
  end

  it_behaves_like 'a command that requires a user to have a current_pokemon' do
    let(:command) { described_class.new('12345') }
  end

  describe '#call' do
    let(:repos) { Pokecord::Repos.new }
    let!(:pokemon) { TestingFactory[:pokemon, name: 'Freight Train'] }
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
        discord_id: '192837',
        current_pokemon_id: spawn.id
      ]
    end
    let!(:product) do
      TestingFactory[
        :product,
        name: 'OK GO'
      ]
    end

    subject { described_class.new('192837').call }

    context 'if current_pokemon does not have a held_item' do
      it 'returns a failure monad' do
        expect { subject }.not_to change { repos.inventory_items.count }.from(0)
      end
    end

    context 'if current_pokemon does have a held_item' do
      let!(:held_item) do
        TestingFactory[
          :held_item,
          spawned_pokemon_id: spawn.id,
          product_id: product.id
        ]
      end

      context 'if user has an inventory_item for the held_item.product' do
        let!(:inventory_item) do
          TestingFactory[
            :inventory_item,
            product_id: product.id,
            user_id: user.id,
            amount: 15
          ]
        end

        context 'if current_pokemon has a nickname' do
          let(:nickname) { 'The Lodger' }

          it 'returns a success message wrapped in a success monad' do
            expect { subject }.to change {
              repos.inventory_items.by_pk(inventory_item.id).one.amount
            }.from(15).to(16)
            expect(subject).to be_success
            expect(subject.value!).to eq(
              I18n.t('take.success', product_name: 'OK GO', pokemon_name: 'The Lodger')
            )
          end
        end

        context 'if current_pokemon does not have a nickname' do
          it 'returns a success message wrapped in a success monad' do
            expect { subject }.to change {
              repos.inventory_items.by_pk(inventory_item.id).one.amount
            }.from(15).to(16)
            expect(subject).to be_success
            expect(subject.value!).to eq(
              I18n.t('take.success', product_name: 'OK GO', pokemon_name: 'Freight Train')
            )
          end
        end
      end

      context 'if user does not have an inventory_item for the held_item.product' do
        context 'if current_pokemon has a nickname' do
          let(:nickname) { 'The Ripper' }

          it 'returns a success message wrapped in a success monad' do
            expect { subject }.to change {
              repos.inventory_items.count
            }.from(0).to(1)
            inventory_item = repos.
              inventory_items.
              where(user_id: user.id, product_id: product.id).
              one
            expect(inventory_item.amount).to eq(1)
            expect(subject).to be_success
            expect(subject.value!).to eq(
              I18n.t('take.success', product_name: 'OK GO', pokemon_name: 'The Ripper')
            )
          end
        end

        context 'if current_pokemon does not have a nickname' do
          it 'returns a success message wrapped in a success monad' do
            expect { subject }.to change {
              repos.inventory_items.count
            }.from(0).to(1)
            inventory_item = repos.
              inventory_items.
              where(user_id: user.id, product_id: product.id).
              one
            expect(inventory_item.amount).to eq(1)
            expect(subject).to be_success
            expect(subject.value!).to eq(
              I18n.t('take.success', product_name: 'OK GO', pokemon_name: 'Freight Train')
            )
          end
        end
      end
    end
  end
end
