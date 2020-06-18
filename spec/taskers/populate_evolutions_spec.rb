# frozen_string_literal: true

require_relative '../../lib/taskers/populate_products'
require_relative '../../lib/taskers/populate_evolutions'

RSpec.describe Taskers::PopulateEvolutions do
  describe '#call' do
    let(:pokemon_repo) do
      Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:evolution_repo) do
      Repositories::EvolutionRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:csv_location) { File.expand_path('../support/mock_evolutions.csv', File.dirname(__FILE__)) }
    let(:mock_outpt) { double('STDOUT') }
    let(:tasker) { described_class.new(csv_location, mock_outpt) }

    subject { tasker.call }

    before do
      allow(mock_outpt).to receive(:puts).with(instance_of(String))
      # Pokemon must exist before populating evolutions
      (1..35).each do |pokedex_number|
        TestingFactory[
          :pokemon,
          pokedex_number: pokedex_number
        ]
      end
      # Products must exist before populating evolutions that rely on them
      Taskers::PopulateProducts.new(mock_outpt).call
    end

    it 'populates evolutions based on the given CSV' do
      expect { subject }.to change {
        evolution_repo.evolutions.count
      }.from(0).to(34)

      # check mock_evolutions.csv for content
      poke1 = pokemon_repo.pokemons.where(pokedex_number: 1).one!
      poke2 = pokemon_repo.pokemons.where(pokedex_number: 2).one!
      evo1 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke1.id, evolves_into_id: poke2.id).
        one!
      expect(evo1.triggered_by).to eq(:level_up)
      expect(evo1.level_requirement).to eq(16)
      expect(evo1.product).to be_nil
      expect(evo1.prerequisites_enum).to eq(0)

      poke3 = pokemon_repo.pokemons.where(pokedex_number: 3).one!
      evo2 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke2.id, evolves_into_id: poke3.id).
        one!
      expect(evo2.triggered_by).to eq(:item)
      expect(evo2.level_requirement).to eq(32)
      expect(evo2.product.name).to eq('Fire Stone')
      expect(evo2.prerequisites_enum).to eq(1)

      poke4 = pokemon_repo.pokemons.where(pokedex_number: 4).one!
      evo3 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke3.id, evolves_into_id: poke4.id).
        one!
      expect(evo3.triggered_by).to eq(:trade)
      expect(evo3.level_requirement).to eq(16)
      expect(evo3.product.name).to eq('Water Stone')
      expect(evo3.prerequisites_enum).to eq(2)

      poke5 = pokemon_repo.pokemons.where(pokedex_number: 5).one!
      evo4 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke4.id, evolves_into_id: poke5.id).
        one!
      expect(evo4.triggered_by).to eq(:trade)
      expect(evo4.level_requirement).to eq(36)
      expect(evo4.product.name).to eq('Thunder Stone')
      expect(evo4.prerequisites_enum).to eq(3)

      poke6 = pokemon_repo.pokemons.where(pokedex_number: 6).one!
      evo5 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke5.id, evolves_into_id: poke6.id).
        one!
      expect(evo5.triggered_by).to eq(:item)
      expect(evo5.level_requirement).to eq(16)
      expect(evo5.product.name).to eq('Leaf Stone')
      expect(evo5.prerequisites_enum).to eq(4)

      poke7 = pokemon_repo.pokemons.where(pokedex_number: 7).one!
      evo6 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke6.id, evolves_into_id: poke7.id).
        one!
      expect(evo6.triggered_by).to eq(:level_up)
      expect(evo6.level_requirement).to eq(36)
      expect(evo6.product.name).to eq('Moon Stone')
      expect(evo6.prerequisites_enum).to be_nil

      poke14 = pokemon_repo.pokemons.where(pokedex_number: 14).one!
      poke15 = pokemon_repo.pokemons.where(pokedex_number: 15).one!
      evo14 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke14.id, evolves_into_id: poke15.id).
        one!
      expect(evo14.triggered_by).to eq(:item)
      expect(evo14.level_requirement).to eq(20)
      expect(evo14.product.name).to eq("King's Rock")
      expect(evo14.prerequisites_enum).to eq(0)

      poke18 = pokemon_repo.pokemons.where(pokedex_number: 18).one!
      poke19 = pokemon_repo.pokemons.where(pokedex_number: 19).one!
      evo18 = evolution_repo.
        evolutions.
        combine(:product).
        where(evolves_from_id: poke18.id, evolves_into_id: poke19.id).
        one!
      expect(evo18.triggered_by).to eq(:trade)
      expect(evo18.level_requirement).to eq(16)
      expect(evo18.product.name).to eq("King's Scale")
      expect(evo18.prerequisites_enum).to eq(1)
    end
  end
end
