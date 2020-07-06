# frozen_string_literal: true

require_relative '../../lib/repositories/product_repo'

RSpec.describe Repositories::ProductRepo do
  describe '#purchasable_products' do
    let(:product_repo) { described_class.new(Db::Connection.registered_container) }
    let!(:product) do
      TestingFactory[
        :product,
        name: 'Rain Stone',
        page_num: 15,
      ]
    end

    subject { product_repo.purchasable_products(page_num) }

    context 'if product does not match the given page number' do
      let(:page_num) { 14 }

      it 'does not include the product' do
        expect(subject.to_a.map(&:id)).not_to include(product.id)
      end
    end

    context 'if product does match the given page number' do
      let(:page_num) { 15 }
      let!(:product) do
        TestingFactory[
          :product,
          name: 'Blood Stone',
          visible: visibility,
          page_num: 15,
          position: 7
        ]
      end

      context 'if product is not visible' do
        let(:visibility) { false }

        it 'does not include the product' do
          expect(subject.to_a.map(&:id)).not_to include(product.id)
        end
      end

      context 'if product is visible' do
        let(:visibility) { true }

        before do
          TestingFactory[
            :product,
            name: 'Fact Stone',
            visible: true,
            page_num: 15,
            position: 6
          ]
          TestingFactory[
            :product,
            name: 'Zebra Tears',
            visible: true,
            page_num: 15,
            position: 7
          ]
          TestingFactory[
            :product,
            name: 'April Rain',
            visible: true,
            page_num: 15,
            position: 7
          ]
          TestingFactory[
            :product,
            name: 'Fiction Rock',
            visible: true,
            page_num: 15,
            position: 8
          ]
        end

        it 'orders the product by position then name' do
          expect(subject.to_a.map(&:name)).to eq(
            [
              'Fact Stone',
              'April Rain',
              'Blood Stone',
              'Zebra Tears',
              'Fiction Rock'
            ]
          )
        end
      end
    end
  end
end
