# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/alter_fav'

RSpec.describe Pokecord::Commands::AlterFav do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345', 35, true) }
  end

  describe '#call' do
    let!(:user) { TestingFactory[:user, discord_id: '12234'] }
    let(:fav_value) { true }
    let(:alter_fav_command) { described_class.new('12234', 233, fav_value) }

    subject { alter_fav_command.call }

    context 'if user does not have any spawns' do
      it 'returns a failure monad' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(I18n.t('alter_fav.no_pokemon_found'))
      end
    end

    context 'if user has spawns' do
      context 'if none of the spawns match the given catch number' do
        before do
          TestingFactory[
            :spawned_pokemon,
            user_id: user.id,
            catch_number: 232
          ]
        end

        it 'returns a failure monad' do
          expect(subject).to be_failure
          expect(subject.failure).to eq(I18n.t('alter_fav.no_pokemon_found'))
        end
      end

      context 'if a spawn matches the catch number' do
        let(:spawn_repo) do
          Repositories::SpawnedPokemonRepo.new(
            Db::Connection.registered_container
          )
        end
        let(:pokemon) { TestingFactory[:pokemon, name: 'Charizard'] }
        let(:spawn) do
          TestingFactory[
            :spawned_pokemon,
            pokemon_id: pokemon.id,
            user_id: user.id,
            catch_number: 233,
            favorite: previous_fav_value,
            nickname: nickname
          ]
        end

        context 'if fav_value is true' do
          let(:previous_fav_value) { false }
          let(:fav_value) { true }

          context 'if spawn has a nickname' do
            let(:nickname) { 'Sally' }

            it 'returns a success message wrapped in a success monad' do
              expect { subject }.to change {
                spawn_repo.spawned_pokemons.by_pk(spawn.id).one.favorite
              }.from(false).to(true)
              expect(subject).to be_success
              expect(subject.value!).to eq(I18n.t('alter_fav.add_success', spawn_name: 'Sally'))
            end
          end

          context 'if spawn does not have a nickname' do
            let(:nickname) { nil }

            it 'returns a success message wrapped in a success monad' do
              expect { subject }.to change {
                spawn_repo.spawned_pokemons.by_pk(spawn.id).one.favorite
              }.from(false).to(true)
              expect(subject).to be_success
              expect(subject.value!).to eq(I18n.t('alter_fav.add_success', spawn_name: 'Charizard'))
            end
          end
        end

        context 'if fav_value is false' do
          let(:previous_fav_value) { true }
          let(:fav_value) { false }

          context 'if spawn has a nickname' do
            let(:nickname) { 'Sally' }

            it 'returns a success message wrapped in a success monad' do
              expect { subject }.to change {
                spawn_repo.spawned_pokemons.by_pk(spawn.id).one.favorite
              }.from(true).to(false)
              expect(subject).to be_success
              expect(subject.value!).to eq(I18n.t('alter_fav.remove_success', spawn_name: 'Sally'))
            end
          end

          context 'if spawn does not have a nickname' do
            let(:nickname) { nil }

            it 'returns a success message wrapped in a success monad' do
              expect { subject }.to change {
                spawn_repo.spawned_pokemons.by_pk(spawn.id).one.favorite
              }.from(true).to(false)
              expect(subject).to be_success
              expect(subject.value!).to eq(I18n.t('alter_fav.remove_success', spawn_name: 'Charizard'))
            end
          end
        end
      end
    end
  end
end
