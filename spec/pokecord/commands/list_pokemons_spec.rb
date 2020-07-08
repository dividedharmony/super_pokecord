# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/list_pokemons'

RSpec.describe Pokecord::Commands::ListPokemons do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345', 1) }
  end

  describe '#call' do
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: '24680'
      ]
    end
    let(:page_offset) { 0 }

    subject { described_class.new('24680', page_offset, only_favorites).call }

    context 'if only_favorites is false' do
      let(:only_favorites) { false }

      context 'if user has no spawns' do
        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(
            I18n.t('list_pokemon.no_pokemon_found')
          )
        end
      end

      context 'if user has spawns' do
        context 'if page_offset is 0' do
          let!(:spawn) { TestingFactory[:spawned_pokemon, user_id: user.id] }

          it 'returns a list payload wrapped in a success monad' do
            expect(subject).to be_success
            payload = subject.value!
            expect(payload.spawned_pokemons.length).to eq(1)
            expect(payload.spawned_pokemons.first.id).to eq(spawn.id)
            expect(payload.page_number).to eq(1)
            expect(payload.total_pages).to eq(1)
          end
        end

        context 'if page_offset is greater than 0' do
          let(:page_offset) { 1 }

          before do
            51.times do |n|
              TestingFactory[
                :spawned_pokemon,
                user_id: user.id,
                nickname: "Name #{n + 1}"
              ]
            end
          end

          it 'returns a list payload offset by the page number wrapped in a success monad' do
            expect(subject).to be_success
            payload = subject.value!
            expect(payload.spawned_pokemons.length).to eq(25)
            expect(payload.spawned_pokemons.map(&:nickname)).to match_array(
              (26..50).map { |n| "Name #{n}" }
            )
            expect(payload.page_number).to eq(2)
            expect(payload.total_pages).to eq(3)
          end
        end
      end
    end

    context 'if only_favorites is true' do
      let(:only_favorites) { true }

      context 'if user has no favorite spawns' do
        before do
          TestingFactory[
            :spawned_pokemon,
            user_id: user.id,
            favorite: false
          ]
        end

        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(
            I18n.t('list_pokemon.no_pokemon_found')
          )
        end
      end

      context 'if user has favorite spawns' do
        let!(:spawn) do
          TestingFactory[
            :spawned_pokemon,
            user_id: user.id,
            favorite: true
          ]
        end

        it 'returns a list payload wrapped in a success monad' do
          expect(subject).to be_success
          payload = subject.value!
          expect(payload.spawned_pokemons.length).to eq(1)
          expect(payload.spawned_pokemons.first.id).to eq(spawn.id)
          expect(payload.page_number).to eq(1)
          expect(payload.total_pages).to eq(1)
        end
      end
    end
  end
end
