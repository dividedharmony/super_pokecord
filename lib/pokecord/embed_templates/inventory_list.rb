# frozen_string_literal: true

require 'discordrb'

require_relative '../embed_templates'

module Pokecord
  module EmbedTemplates
    class InventoryList
      def initialize(username, inventory_items)
        @username = username
        @inventory_items = inventory_items
      end

      def to_embed
        embed = Discordrb::Webhooks::Embed.new(
          color: Pokecord::EmbedTemplates::EMBED_COLOR,
          title: "#{username}'s Inventory",
          description: I18n.t('inventory.description')
        )
        inventory_items.each do |item|
          embed.add_field(
            name: item.product.name,
            value: "Amount: #{item.amount}",
            inline: true
          )
        end
        # @return [Discordrb::Webhooks::Embed]
        embed
      end

      private

      attr_reader :username, :inventory_items
    end
  end
end
