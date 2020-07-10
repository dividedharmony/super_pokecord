# frozen_string_literal: true

require_relative '../../lib/pokecord/repos'

RSpec.describe Pokecord::Repos do
  let(:repos) { described_class.new }

  describe '#spawn_repo' do
    subject { repos.spawn_repo }

    it { is_expected.to be_a(Repositories::SpawnedPokemonRepo) }
  end

  describe '#pokemon_repo' do
    subject { repos.pokemon_repo }

    it { is_expected.to be_a(Repositories::PokemonRepo) }
  end

  describe '#evolution_repo' do
    subject { repos.evolution_repo }

    it { is_expected.to be_a(Repositories::EvolutionRepo) }
  end

  describe '#user_repo' do
    subject { repos.user_repo }

    it { is_expected.to be_a(Repositories::UserRepo) }
  end

  describe '#product_repo' do
    subject { repos.product_repo }

    it { is_expected.to be_a(Repositories::ProductRepo) }
  end

  describe '#fight_type_repo' do
    subject { repos.fight_type_repo }

    it { is_expected.to be_a(Repositories::FightTypeRepo) }
  end

  describe '#fight_event_repo' do
    subject { repos.fight_event_repo }

    it { is_expected.to be_a(Repositories::FightEventRepo) }
  end

  describe '#inventory_repo' do
    subject { repos.inventory_repo }

    it { is_expected.to be_a(Repositories::InventoryItemRepo) }
  end

  describe '#trade_repo' do
    subject { repos.trade_repo }

    it { is_expected.to be_a(Repositories::TradeRepo) }
  end

  describe '#spawned_pokemons' do
    let!(:spawned_pokemon) { TestingFactory[:spawned_pokemon] }

    subject { repos.spawned_pokemons }

    it 'returns the spawned_pokemons relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(spawned_pokemon.id)
    end
  end

  describe '#pokemons' do
    let!(:pokemon) { TestingFactory[:pokemon] }

    subject { repos.pokemons }

    it 'returns the pokemon relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(pokemon.id)
    end
  end

  describe '#evolutions' do
    let!(:evolution) { TestingFactory[:evolution] }

    subject { repos.evolutions }

    it 'returns the evolutions relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(evolution.id)
    end
  end

  describe '#users' do
    let!(:user) { TestingFactory[:user] }

    subject { repos.users }

    it 'returns the users relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(user.id)
    end
  end

  describe '#products' do
    let!(:product) { TestingFactory[:product] }

    subject { repos.products }

    it 'returns the products relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(product.id)
    end
  end

  describe '#fight_types' do
    let!(:fight_type) { TestingFactory[:fight_type] }

    subject { repos.fight_types }

    it 'returns the fight_types relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(fight_type.id)
    end
  end

  describe '#fight_events' do
    let!(:fight_event) { TestingFactory[:fight_event] }

    subject { repos.fight_events }

    it 'returns the fight_events relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(fight_event.id)
    end
  end

  describe '#inventory_items' do
    let!(:inventory_item) { TestingFactory[:inventory_item] }

    subject { repos.inventory_items }

    it 'returns the inventory_items relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(inventory_item.id)
    end
  end

  describe '#trades' do
    let!(:trade) { TestingFactory[:trade] }

    subject { repos.trades }

    it 'returns the trades relation' do
      expect(subject.count).to eq(1)
      expect(subject.first.id).to eq(trade.id)
    end
  end
end
