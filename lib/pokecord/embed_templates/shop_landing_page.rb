# frozen_string_literal: true

require 'discordrb'

require_relative '../embed_templates'

module Pokecord
  module EmbedTemplates
    class ShopLandingPage
      def initialize
        @embed = Discordrb::Webhooks::Embed.new(
          color: Pokecord::EmbedTemplates::EMBED_COLOR,
          title: "Poke Shop",
          description: I18n.t('shop.landing_page.description')
        )
      end

      def to_embed
        embed.add_field(
          name: 'Page 1 |',
          value: 'Rare Stones & Evolution Items'
        )
        embed.add_field(
          name: 'Page 2 | [Not Implemented]',
          value: 'Mega Evolutions'
        )
        embed.add_field(
          name: 'Page 3 | [Not Implemented]',
          value: 'XP Boosters & Rare Candies'
        )
        embed.add_field(
          name: 'Page 4 | [Not Implemented]',
          value: 'Lootboxes'
        )
        embed
      end

      private

      attr_reader :embed
    end
  end
end
