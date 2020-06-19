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

    subject { described_class.new(spawned_pokemon).call }

    before do
      expect_any_instance_of(Repositories::EvolutionRepo).
        to receive(:level_up_evolutions).
        with(spawned_pokemon) { evo_repo.evolutions }
    end

    context 'if there are no level_up_evolutions for spawned_pokemon' do
      it 'returns a failure monad' do
        expect { subject }.not_to change {
          spawn_repo.spawned_pokemons.by_pk(spawned_pokemon.id).one.pokemon_id
        }.from(original_pokemon.id)
        expect(subject).to be_failure
      end
    end

    context 'if there are level_up_evolutions for spawned_pokemon' do
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
