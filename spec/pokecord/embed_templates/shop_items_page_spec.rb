# frozen_string_literal: true

require_relative '../../../lib/pokecord/embed_templates/shop_items_page'

RSpec.describe Pokecord::EmbedTemplates::ShopItemsPage do
  describe '#to_embed' do
    subject { described_class.new(page_number).to_embed }

    before do
      TestingFactory[
        :product,
        name: "Fire Stone",
        visible: true,
        price: 12_000,
        page_num: 1
      ]
      TestingFactory[
        :product,
        name: "Mega Y",
        visible: true,
        price: 125_000,
        page_num: 2
      ]
      TestingFactory[
        :product,
        name: "XP Boost x9",
        visible: true,
        price: 250,
        page_num: 3
      ]
      TestingFactory[
        :product,
        name: "Epic Lootbox",
        visible: true,
        price: 1_500_000,
        page_num: 4
      ]
    end

    context 'if the page_number is 1' do
      let(:page_number) { 1 }

      it 'returns an embed with the relevant information' do
        expect(subject.title).to eq("Poke Shop | #{I18n.t('shop.1.title')}")
        expect(subject.description).to eq(
          I18n.t('shop.1.description') + "\n\n" + I18n.t('shop.purchase_instructions')
        )
        expect(subject.fields[0].name).to eq('Fire Stone')
        expect(subject.fields[0].value).to eq('12,000 credits')
      end
    end

    context 'if the page_number is 2' do
      let(:page_number) { 2 }

      it 'returns an embed with the relevant information' do
        expect(subject.title).to eq("Poke Shop | #{I18n.t('shop.2.title')}")
        expect(subject.description).to eq(
          I18n.t('shop.2.description') + "\n\n" + I18n.t('shop.purchase_instructions')
        )
        expect(subject.fields[0].name).to eq('Mega Y')
        expect(subject.fields[0].value).to eq('125,000 credits')
      end
    end

    context 'if the page_number is 3' do
      let(:page_number) { 3 }

      it 'returns an embed with the relevant information' do
        expect(subject.title).to eq("Poke Shop | #{I18n.t('shop.3.title')}")
        expect(subject.description).to eq(
          I18n.t('shop.3.description') + "\n\n" + I18n.t('shop.purchase_instructions')
        )
        expect(subject.fields[0].name).to eq('XP Boost x9')
        expect(subject.fields[0].value).to eq('250 credits')
      end
    end

    context 'if the page_number is 4' do
      let(:page_number) { 4 }

      it 'returns an embed with the relevant information' do
        expect(subject.title).to eq("Poke Shop | #{I18n.t('shop.4.title')}")
        expect(subject.description).to eq(
          I18n.t('shop.4.description') + "\n\n" + I18n.t('shop.purchase_instructions')
        )
        expect(subject.fields[0].name).to eq('Epic Lootbox')
        expect(subject.fields[0].value).to eq('1,500,000 credits')
      end
    end
  end
end
