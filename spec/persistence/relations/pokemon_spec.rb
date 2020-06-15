# frozen_string_literal: true

require_relative '../../../lib/persistence/relations/pokemons'
require_relative '../../../db/connection'
require_relative '../../../lib/repositories/pokemon_repo'

RSpec.describe Persistence::Relations::Pokemons do
  describe 'associations' do
    describe '#spawned_pokemons' do
      let!(:pokemon) { TestingFactory[:pokemon] }
      let!(:spawned_pokemon) { TestingFactory[:spawned_pokemon, pokemon: pokemon] }
      let!(:pokemon_repo) do
        Repositories::PokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        pokemon_repo.
          pokemons.
          combine(:spawned_pokemons).
          where(id: pokemon.id).
          one!
      end

      it 'has_many spawned_pokemons' do
        expect(subject.spawned_pokemons.map(&:id)).to contain_exactly(spawned_pokemon.id)
      end
    end

    describe '#progressive_evolutions' do
      let!(:pokemon) { TestingFactory[:pokemon] }
      let!(:evolution) { TestingFactory[:evolution, evolves_from_id: pokemon.id] }
      let!(:pokemon_repo) do
        Repositories::PokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        pokemon_repo.
          pokemons.
          combine(:progressive_evolutions).
          where(id: pokemon.id).
          one!
      end

      it 'has_many progressive_evolutions' do
        expect(subject.progressive_evolutions.map(&:id)).to contain_exactly(evolution.id)
      end
    end

    describe '#regressive_evolutions' do
      let!(:pokemon) { TestingFactory[:pokemon] }
      let!(:evolution) { TestingFactory[:evolution, evolves_into_id: pokemon.id] }
      let!(:pokemon_repo) do
        Repositories::PokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        pokemon_repo.
          pokemons.
          combine(:regressive_evolutions).
          where(id: pokemon.id).
          one!
      end

      it 'has_many regressive_evolutions' do
        expect(subject.regressive_evolutions.map(&:id)).to contain_exactly(evolution.id)
      end
    end
  end
end
