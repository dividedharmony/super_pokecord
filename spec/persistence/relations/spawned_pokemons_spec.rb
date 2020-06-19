# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../../lib/repositories/spawned_pokemon_repo'

RSpec.describe Persistence::Relations::SpawnedPokemons do
  describe 'associations' do
    describe '.trade' do
      let!(:trade) { TestingFactory[:trade] }
      let!(:user) { TestingFactory[:spawned_pokemon, trade_id: trade.id] }
      let(:spawn_repo) do
        Repositories::SpawnedPokemonRepo.new(
          Db::Connection.registered_container
        )
      end

      subject do
        spawn_repo.spawned_pokemons.combine(:trade).first
      end

      it 'relates to a user record' do
        expect(subject.trade.id).to eq trade.id
      end
    end
  end
end
