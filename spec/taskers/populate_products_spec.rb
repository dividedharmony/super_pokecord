# frozen_string_literal: true

require_relative '../../lib/taskers/populate_products'

RSpec.describe Taskers::PopulateProducts do
  describe '#call' do
    let(:product_repo) do
      Repositories::ProductRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:mock_output) { double('STDOUT') }

    subject { described_class.new(mock_output).call }

    before do
      allow(mock_output).to receive(:puts).with(instance_of(String))
    end

    context 'if a product listed already exists' do
      let!(:product) do
        TestingFactory[
          :product,
          name: 'Water Stone',
          visible: false,
          price: 12,
          page_num: 18,
          position: 209
        ]
      end

      it 'updates the product with the new attributes' do
        expect { subject }.to change {
          product_repo.products.by_pk(product.id).one.visible
        }.from(false).to(true)
        reloaded_product = product_repo.products.by_pk(product.id).one
        expect(reloaded_product.price).to eq(25_000)
        expect(reloaded_product.page_num).to eq(1)
        expect(reloaded_product.position).to eq(2)
      end
    end

    context 'if no products listed already exists' do
      it 'populates the fight_types' do
        expect { subject }.to change {
          product_repo.products.count
        }.from(0).to(33)
        expect(product_repo.products.to_a.map(&:name)).to contain_exactly(
          'Fire Stone',
          'Water Stone',
          'Thunder Stone',
          'Leaf Stone',
          'Moon Stone',
          'Sun Stone',
          'Shiny Stone',
          'Dusk Stone',
          'Dawn Stone',
          'Ice Stone',
          'Oval Stone',
          'Friendship Bracelet',
          "King's Rock",
          'Powerful Magnet',
          'Metal Coat',
          'Protector',
          "King's Scale",
          'Electirizer',
          'Magmarizer',
          'Upgrade',
          'Dubious Disc',
          'Razor Fang',
          'Prism Scale',
          'Reaper Cloth',
          'Deep Sea Tooth',
          'Deep Sea Scale',
          'Sachet',
          'Whipped Dream',
          'Meltan Candy',
          'Tart Apple',
          'Sweet Apple',
          'Cracked Pot',
          'Strawberry Sweet'
        )
      end
    end
  end
end
