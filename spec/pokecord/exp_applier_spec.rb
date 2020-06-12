# frozen_string_literal: true

require_relative '../../lib/pokecord/exp_applier'

RSpec.describe Pokecord::ExpApplier do
  describe '#apply!' do
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:starting_level) { 12 }
    let(:current_exp) { 0 }
    let(:required_exp) { 750 }
    let(:spawned_pokemon) do
      TestingFactory[
        :spawned_pokemon,
        :caught,
        level: starting_level,
        current_exp: current_exp,
        required_exp: required_exp
      ]
    end
    let(:incoming_exp) { 53 }
    let(:exp_applier) { described_class.new(spawned_pokemon, incoming_exp) }

    subject { exp_applier.apply! }

    context 'if the given pokemon has a level less than 1' do
      let(:starting_level) { 0 }

      it 'does nothing' do
        expect { subject }.not_to change {
          spawn_repo.spawned_pokemons.where(id: spawned_pokemon.id).one.current_exp
        }.from(0)
        expect(exp_applier.payload).to be_nil
      end
    end

    context 'if the given pokemon has a level between 1 and 99' do
      context 'if incoming_exp plus current_exp is greater than or equal to required_exp' do
        let(:starting_level) { 10 }
        let(:incoming_exp) { 60 }
        let(:current_exp) { 740 }
        let(:required_exp) { 750 }

        it 'levels up the spawned_pokemon' do
          expect { subject }.to change {
            spawn_repo.spawned_pokemons.where(id: spawned_pokemon.id).one.level
          }.from(10).to(11)
          reloaded_spawn = spawn_repo.spawned_pokemons.where(id: spawned_pokemon.id).one
          expect(reloaded_spawn.current_exp).to eq(50)
          new_required_exp = Pokecord::ExpCurve.new(11).required_exp_for_next_level
          expect(reloaded_spawn.required_exp).to eq(new_required_exp)
          # the applier returns a payload
          level_up_payload = exp_applier.payload
          expect(level_up_payload.spawned_pokemon.id).to eq(reloaded_spawn.id)
          expect(level_up_payload.level).to eq(11)
        end
      end

      context 'if incoming_exp plus current_exp is less than required_exp' do
        let(:starting_level) { 10 }
        let(:incoming_exp) { 60 }
        let(:current_exp) { 670 }
        let(:required_exp) { 750 }

        it 'adds the exp but does not change level' do
          expect { subject }.not_to change {
            spawn_repo.spawned_pokemons.where(id: spawned_pokemon.id).one.level
          }.from(10)
          reloaded_spawn = spawn_repo.spawned_pokemons.where(id: spawned_pokemon.id).one
          expect(reloaded_spawn.current_exp).to eq(730)
          expect(reloaded_spawn.required_exp).to eq(750)
          expect(exp_applier.payload).to be_nil
        end
      end
    end

    context 'if the given pokemon has a level greater than 99' do
      let(:starting_level) { 100 }

      it 'does nothing' do
        expect { subject }.not_to change {
          spawn_repo.spawned_pokemons.where(id: spawned_pokemon.id).one.current_exp
        }.from(0)
        expect(exp_applier.payload).to be_nil
      end
    end
  end
end
