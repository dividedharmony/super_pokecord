# frozen_string_literal: true

require_relative '../../lib/taskers/populate_pokemon_from_csv'

RSpec.describe Taskers::PopulatePokemonFromCsv do
  describe '#call' do
    let(:pokemon_repo) do
      Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:mock_output) { double('STDOUT') }
    let(:csv_location) { File.expand_path('../support/mock_pokemon.csv', File.dirname(__FILE__)) }
    let(:tasker) { described_class.new(csv_location, mock_output) }

    subject { tasker.call }

    before do
      allow(mock_output).to receive(:puts).with(instance_of(String))
    end

    context 'if row has an "x" in the starter column' do
      # check the mock_pokemon.csv
      # the first row has an "x" in it
      it 'creates a pokemon and sets it as a starter' do
        expect { subject }.to change {
          pokemon_repo.pokemons.count
        }.from(0).to(2)
        pokemon = pokemon_repo.pokemons.where(pokedex_number: 810).one!
        expect(pokemon.name).to eq('Grookey')
        expect(pokemon.starter).to be true
        expect(pokemon.base_hp).to eq(50)
        expect(pokemon.base_attack).to eq(65)
        expect(pokemon.base_defense).to eq(50)
        expect(pokemon.base_sp_attack).to eq(40)
        expect(pokemon.base_sp_defense).to eq(40)
        expect(pokemon.base_speed).to eq(65)
        expect(pokemon.created_at).to be_within(5).of(Time.now)
      end
    end

    context 'if row does not have an "x" in the starter column' do
      # check the mock_pokemon.csv
      # the second row does not have an "x" in it
      it 'creates a pokemon and does not set it as a starter' do
        expect { subject }.to change {
          pokemon_repo.pokemons.count
        }.from(0).to(2)
        pokemon = pokemon_repo.pokemons.where(pokedex_number: 811).one!
        expect(pokemon.name).to eq('Thwackey')
        expect(pokemon.starter).to be false
        expect(pokemon.base_hp).to eq(70)
        expect(pokemon.base_attack).to eq(85)
        expect(pokemon.base_defense).to eq(70)
        expect(pokemon.base_sp_attack).to eq(55)
        expect(pokemon.base_sp_defense).to eq(60)
        expect(pokemon.base_speed).to eq(80)
        expect(pokemon.created_at).to be_within(5).of(Time.now)
      end
    end
  end
end
