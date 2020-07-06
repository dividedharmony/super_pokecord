# frozen_string_literal: true

require_relative '../../../lib/pokecord/embed_templates/shop_landing_page'

RSpec.describe Pokecord::EmbedTemplates::ShopLandingPage do
  describe '#to_embed' do
    subject { described_class.new.to_embed }

    it 'returns an embed with all of the expected values' do
      expect(subject.title).to eq('Poke Shop')
      expect(subject.color).to eq(3463403)
      expect(subject.description).to eq(
        I18n.t('shop.landing_page.description')
      )
      expect(subject.fields[0].name).to eq('Page 1 |')
      expect(subject.fields[0].value).to eq('Rare Stones & Evolution Items')
      expect(subject.fields[1].name).to eq('Page 2 | [Not Implemented]')
      expect(subject.fields[1].value).to eq('Mega Evolutions')
      expect(subject.fields[2].name).to eq('Page 3 | [Not Implemented]')
      expect(subject.fields[2].value).to eq('XP Boosters & Rare Candies')
      expect(subject.fields[3].name).to eq('Page 4 | [Not Implemented]')
      expect(subject.fields[3].value).to eq('Lootboxes')
    end
  end
end
