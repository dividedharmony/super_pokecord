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
          value: I18n.t('shop.1.title')
        )
        embed.add_field(
          name: 'Page 2 | [Not Implemented]',
          value: I18n.t('shop.2.title')
        )
        embed.add_field(
          name: 'Page 3 | [Not Implemented]',
          value: I18n.t('shop.3.title')
        )
        embed.add_field(
          name: 'Page 4 | [Not Implemented]',
          value: I18n.t('shop.4.title')
        )
        embed
      end

      private

      attr_reader :embed
    end
  end
end
