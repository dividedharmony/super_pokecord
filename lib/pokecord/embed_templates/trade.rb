# frozen_string_literal: true

require 'discordrb'

require_relative '../../../db/connection'
require_relative '../../repositories/spawned_pokemon_repo'
require_relative '../../repositories/trade_repo'

require_relative '../embed_templates'
require_relative '../embed_templates/offering_list'

module Pokecord
  module EmbedTemplates
    class Trade
      def initialize(trade)
        @trade = trade
      end

      def to_embed
        embed = Discordrb::Webhooks::Embed.new(
          color: Pokecord::EmbedTemplates::EMBED_COLOR,
          title: "Trade between #{trade.user_1_name} and #{trade.user_2_name}",
          description: I18n.t('trade.how_to_trade_description')
        )
        embed.add_field(
          name: "#{trade.user_1_name} is offering |",
          value: Pokecord::EmbedTemplates::OfferingList.new(trade.user_1_id, trade.id).to_s
        )
        embed.add_field(
          name: "#{trade.user_2_name} is offering |",
          value: Pokecord::EmbedTemplates::OfferingList.new(trade.user_2_id, trade.id).to_s
        )
        embed
      end

      private

      attr_reader :trade
    end
  end
end
