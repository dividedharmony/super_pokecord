# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../../lib/repositories/pokemon_repo'

RSpec.describe Entities::Pokemon do
  let(:pokemon_repo) do
    Repositories::PokemonRepo.new(
      Db::Connection.registered_container
    )
  end

  describe '#stylized_pokedex_number' do
    before do
      TestingFactory[:pokemon, pokedex_number: pokedex_number]
    end

    let(:pokemon) { pokemon_repo.pokemons.first }

    subject { pokemon.stylized_pokedex_number }

    context 'if pokedex_number is one digit long' do
      let(:pokedex_number) { 5 }

      it { is_expected.to eq('005') }
    end

    context 'if pokedex_number is two digits long' do
      let(:pokedex_number) { 34 }

      it { is_expected.to eq('034') }
    end

    context 'if pokedex_number is three digits long' do
      let(:pokedex_number) { 821 }

      it { is_expected.to eq('821') }
    end
  end

  describe '#relative_image_path' do
    before do
      TestingFactory[:pokemon, pokedex_number: 69]
    end

    let(:pokemon) { pokemon_repo.pokemons.first }

    subject { pokemon.relative_image_path }

    it { is_expected.to eq('./pokemon_info/images/069.png') }
  end
end
