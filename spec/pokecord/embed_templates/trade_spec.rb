# frozen_string_literal: true

require_relative '../../../lib/pokecord/embed_templates/trade'

RSpec.describe Pokecord::EmbedTemplates::Trade do
  describe '#to_embed' do
    let(:trade) do
      TestingFactory[
        :trade,
        user_1_name: 'Josh Gad',
        user_2_name: 'Elsa from Frozen'
      ]
    end
    let(:embed_template) { described_class.new(trade) }

    before do
      mock_offering_1 = instance_double(Pokecord::EmbedTemplates::OfferingList)
      mock_offering_2 = instance_double(Pokecord::EmbedTemplates::OfferingList)
      expect(Pokecord::EmbedTemplates::OfferingList).
        to receive(:new).with(trade.user_1_id, trade.id) { mock_offering_1 }
      expect(Pokecord::EmbedTemplates::OfferingList).
        to receive(:new).with(trade.user_2_id, trade.id) { mock_offering_2 }
      expect(mock_offering_1).to receive(:to_s) { "Offering list #1" }
      expect(mock_offering_2).to receive(:to_s) { "Offering list #2" }
    end

    subject { embed_template.to_embed }

    it 'returns a Discord Embed' do
      expect(subject).to be_instance_of(Discordrb::Webhooks::Embed)
      expect(subject.color).to eq(3463403)
      expect(subject.description).to eq(I18n.t('trade.how_to_trade_description'))
      expect(subject.fields[0].name).to match(/\AJosh Gad is offering/)
      expect(subject.fields[0].value).to eq('Offering list #1')
      expect(subject.fields[1].name).to match(/\AElsa from Frozen is offering/)
      expect(subject.fields[1].value).to eq('Offering list #2')
    end

    context 'if user_1 has confirmed' do
      let(:trade) do
        TestingFactory[
          :trade,
          user_1_confirm: true,
          user_1_name: 'Josh Gad',
          user_2_name: 'Elsa from Frozen'
        ]
      end

      it 'renders a checkbox next to the user_1 name' do
        expect(subject.fields[0].name).to eq('Josh Gad is offering | :white_check_mark:')
      end
    end

    context 'if user_1 has not confirmed' do
      let(:trade) do
        TestingFactory[
          :trade,
          user_1_confirm: false,
          user_1_name: 'Josh Gad',
          user_2_name: 'Elsa from Frozen'
        ]
      end

      it 'does not render a checkbox next to the user_1 name' do
        expect(subject.fields[0].name).to eq('Josh Gad is offering | ')
      end
    end

    context 'if user_2 has confirmed' do
      let(:trade) do
        TestingFactory[
          :trade,
          user_2_confirm: true,
          user_1_name: 'Josh Gad',
          user_2_name: 'Elsa from Frozen'
        ]
      end

      it 'renders a checkbox next to the user_2 name' do
        expect(subject.fields[1].name).to eq('Elsa from Frozen is offering | :white_check_mark:')
      end
    end

    context 'if user_2 has not confirmed' do
      let(:trade) do
        TestingFactory[
          :trade,
          user_2_confirm: false,
          user_1_name: 'Josh Gad',
          user_2_name: 'Elsa from Frozen'
        ]
      end

      it 'does not render a checkbox next to the user_2 name' do
        expect(subject.fields[1].name).to eq('Elsa from Frozen is offering | ')
      end
    end
  end
end
