# frozen_string_literal: true

require_relative '../../lib/pokecord/evolve'

RSpec.describe Pokecord::Evolve do
  describe '#call' do
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:evo_repo) do
      Repositories::EvolutionRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:original_pokemon) { TestingFactory[:pokemon] }
    let(:spawned_pokemon) do
      TestingFactory[
        :spawned_pokemon,
        pokemon_id: original_pokemon.id
      ]
    end
    let(:item) { nil }

    before do
      expect_any_instance_of(Repositories::EvolutionRepo).
        to receive(:evolutions_by_trigger).
        with(spawned_pokemon, trigger_name) { evo_repo.evolutions }
    end

    subject { described_class.new(spawned_pokemon, trigger_name, item).call }

    context 'if trigger_name is :item' do
      let(:trigger_name) { :item }

      context 'if there are no item evolutions for spawned_pokemon' do
        it 'returns a failure monad' do
          expect { subject }.not_to change {
            spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
          }.from(original_pokemon.id)
          expect(subject).to be_failure
        end
      end

      context 'if there are item evolutions for spawned_pokemon' do
        let(:new_pokemon) { TestingFactory[:pokemon] }
        let(:product) { TestingFactory[:product] }
        let!(:evolution) do
          TestingFactory[
            :evolution,
            evolves_from_id: original_pokemon.id,
            evolves_into_id: new_pokemon.id,
            product_id: product.id
          ]
        end

        context 'if no item is supplied' do
          it 'returns a failure monad' do
            expect { subject }.not_to change {
              spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
            }.from(original_pokemon.id)
            expect(subject).to be_failure
          end
        end

        context 'if an item is supplied' do
          context 'if item does not match required product' do
            let(:item) { TestingFactory[:inventory_item] }

            it 'returns a failure monad' do
              expect { subject }.not_to change {
                spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
              }.from(original_pokemon.id)
              expect(subject).to be_failure
            end
          end

          context 'if item does match required product' do
            let(:item) { TestingFactory[:inventory_item, product_id: product.id] }

            context 'if evolution prerequisites are not fulfilled' do
              before do
                expect_any_instance_of(Entities::Evolution).
                to receive(:prereq_fulfilled?).with(spawned_pokemon) { false }
              end

              it 'returns a failure monad' do
                expect { subject }.not_to change {
                  spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
                }.from(original_pokemon.id)
                expect(subject).to be_failure
              end
            end

            context 'if evolution prerequisites are fulfilled' do
              before do
                expect_any_instance_of(Entities::Evolution).
                  to receive(:prereq_fulfilled?).
                  with(spawned_pokemon).
                  at_most(:twice) { true }
              end

              it 'returns a success monad with the evolved_into pokemon' do
                expect { subject }.to change {
                  spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
                }.from(original_pokemon.id).to(new_pokemon.id)
                expect(subject).to be_success
                expect(subject.value!.id).to eq(new_pokemon.id)
              end
            end
          end
        end
      end
    end

    context 'if trigger_name is not :item' do
      let(:trigger_name) { :level_up }

      context 'if there are no level_up evolutions for spawned_pokemon' do
        it 'returns a failure monad' do
          expect { subject }.not_to change {
            spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
          }.from(original_pokemon.id)
          expect(subject).to be_failure
        end
      end

      context 'if there are level_up evolutions for spawned_pokemon' do
        let(:new_pokemon) { TestingFactory[:pokemon] }
        let!(:evolution) do
          TestingFactory[
            :evolution,
            evolves_from_id: original_pokemon.id,
            evolves_into_id: new_pokemon.id
          ]
        end

        context 'if evolution prerequisites are not fulfilled' do
          before do
            expect_any_instance_of(Entities::Evolution).
            to receive(:prereq_fulfilled?).with(spawned_pokemon) { false }
          end

          it 'returns a failure monad' do
            expect { subject }.not_to change {
              spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
            }.from(original_pokemon.id)
            expect(subject).to be_failure
          end
        end

        context 'if evolution prerequisites are fulfilled' do
          before do
            expect_any_instance_of(Entities::Evolution).
              to receive(:prereq_fulfilled?).
              with(spawned_pokemon).
              at_most(:twice) { true }
          end

          it 'returns a success monad with the evolved_into pokemon' do
            expect { subject }.to change {
              spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
            }.from(original_pokemon.id).to(new_pokemon.id)
            expect(subject).to be_success
            expect(subject.value!.id).to eq(new_pokemon.id)
          end
        end
      end
    end
  end
end
