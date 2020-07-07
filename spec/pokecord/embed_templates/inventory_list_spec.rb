# frozen_string_literal: true

require_relative '../../../lib/pokecord/embed_templates/inventory_list'

RSpec.describe Pokecord::EmbedTemplates::InventoryList do
  describe '#to_embed' do
    let(:username) { 'Larry Birb' }
    let(:product) { TestingFactory[:product, name: 'Diamond Cutter'] }
    let(:inventory_items) do
      [
        TestingFactory[
          :inventory_item,
          product_id: product.id,
          amount: 23
        ]
      ]
    end

    subject { described_class.new(username, inventory_items).to_embed }

    it 'returns a embed' do
      expect(subject.title).to eq("Larry Birb's Inventory")
      expect(subject.description).to eq(I18n.t('inventory.description'))
      expect(subject.fields[0].name).to eq('Diamond Cutter')
      expect(subject.fields[0].value).to eq('Amount: 23')
    end
  end
end
