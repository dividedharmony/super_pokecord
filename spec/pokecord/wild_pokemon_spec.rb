# frozen_string_literal: true

require_relative '../../lib/pokecord/wild_pokemon'

RSpec.describe Pokecord::WildPokemon do
  describe '#spawn!' do
    let(:rand_proc) { Proc.new { |_| 15 } }
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    subject { described_class.new(rand_proc).spawn! }

    before do
      # number returned by proc  + 1
      TestingFactory[:pokemon, pokedex_number: 16]
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
    let(:rand_proc) { Proc.new { |_| 2 } }
    let(:wild_pokemon) { described_class.new(rand_proc) }

    subject { wild_pokemon.pic_file }

    context 'if the pokedex_number has a single digit' do
      before do
        # number returned by proc  + 1
        TestingFactory[:pokemon, pokedex_number: 3]
      end

      # resulting string is zero-padded
      it { is_expected.to match /pokemon_info\/images\/003\.png\z/ }
    end

    context 'if the pokedex_number has a double digits' do
      let(:rand_proc) { Proc.new { |_| 23 } }

      before(:each) do
        # number returned by proc  + 1
        TestingFactory[:pokemon, pokedex_number: 24]
      end

      # resulting string is zero-padded
      it { is_expected.to match /pokemon_info\/images\/024\.png\z/ }
    end

    context 'if the pokedex_number has a triple digits' do
      let(:rand_proc) { Proc.new { |_| 764 } }

      before(:each) do
        # number returned by proc  + 1
        TestingFactory[:pokemon, pokedex_number: 765]
      end

      # no zero-padding
      it { is_expected.to match /pokemon_info\/images\/765\.png\z/ }
    end
  end
end
