# frozen_string_literal: true

require_relative '../../lib/pokecord/wild_pokemon'

RSpec.describe Pokecord::WildPokemon do
  describe '#spawn!' do
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    subject { described_class.new.spawn! }

    before do
      pokemon = TestingFactory[:pokemon, pokedex_number: 16]
      mock_rarity = instance_double(Pokecord::Rarity)
      expect(Pokecord::Rarity).to receive(:new) { mock_rarity }
      expect(mock_rarity).to receive(:random_pokemon) { pokemon }
    end

    it 'returns a spawn of the "randomly" selected pokemon' do
      expect { subject }.to change { spawn_repo.spawned_pokemons.count }.from(0).to(1)
      spawn = spawn_repo.spawned_pokemons.combine(:pokemon).first
      expect(spawn.pokemon.pokedex_number).to eq(16)
      # 3 seconds
      expect(spawn.created_at).to be_within(3).of(Time.now)
      expect(spawn.level).to be_between(1, 49)
      expect(spawn.current_exp).to eq(0)
      expect(spawn.required_exp).to be_between(300, 2_250)
    end
  end

  describe '#pic_file' do
    let(:wild_pokemon) { described_class.new }
    let(:mock_rarity) { instance_double(Pokecord::Rarity) }

    subject { wild_pokemon.pic_file }

    before do
      expect(Pokecord::Rarity).to receive(:new) { mock_rarity }
    end

    context 'if the pokedex_number has a single digit' do
      before do
        pokemon = TestingFactory[:pokemon, pokedex_number: 3]
        expect(mock_rarity).to receive(:random_pokemon) { pokemon }
      end

      # resulting string is zero-padded
      it { is_expected.to match /pokemon_info\/images\/003\.png\z/ }
    end

    context 'if the pokedex_number has a double digits' do
      before(:each) do
        pokemon = TestingFactory[:pokemon, pokedex_number: 24]
        expect(mock_rarity).to receive(:random_pokemon) { pokemon }
      end

      # resulting string is zero-padded
      it { is_expected.to match /pokemon_info\/images\/024\.png\z/ }
    end

    context 'if the pokedex_number has a triple digits' do
      before(:each) do
        pokemon = TestingFactory[:pokemon, pokedex_number: 765]
        expect(mock_rarity).to receive(:random_pokemon) { pokemon }
      end

      # no zero-padding
      it { is_expected.to match /pokemon_info\/images\/765\.png\z/ }
    end
  end
end
