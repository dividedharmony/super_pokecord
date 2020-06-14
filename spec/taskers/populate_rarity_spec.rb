# frozen_string_literal: true

require_relative '../../lib/taskers/populate_rarity'

RSpec.describe Taskers::PopulateRarity do
  describe '#call' do
    let(:pokemon_repo) do
      Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let!(:pokemon) { TestingFactory[:pokemon] }
    let(:csv_location) { File.expand_path('../support/mock_rarity.csv', File.dirname(__FILE__)) }
    let(:mock_outpt) { double('STDOUT') }
    let(:tasker) { described_class.new(csv_location, mock_outpt) }

    subject { tasker.call }

    before do
      allow(mock_outpt).to receive(:puts).with(instance_of(String))
      # Pokemon must exist before populating rarity
      (1..5).each do |pokedex_number|
        TestingFactory[
          :pokemon,
          pokedex_number: pokedex_number,
          rarity_enum: 0
        ]
      end
    end

    it 'populates rarity from the given csv' do
      subject
      # check mock_rarity.csv
      pokemon = pokemon_repo.pokemons.where(pokedex_number: 1).one!
      expect(pokemon.rarity_enum).to eq(0)
      pokemon = pokemon_repo.pokemons.where(pokedex_number: 2).one!
      expect(pokemon.rarity_enum).to eq(1)
      pokemon = pokemon_repo.pokemons.where(pokedex_number: 3).one!
      expect(pokemon.rarity_enum).to eq(2)
      pokemon = pokemon_repo.pokemons.where(pokedex_number: 4).one!
      expect(pokemon.rarity_enum).to eq(3)
      pokemon = pokemon_repo.pokemons.where(pokedex_number: 5).one!
      expect(pokemon.rarity_enum).to eq(4)
    end
  end
end
