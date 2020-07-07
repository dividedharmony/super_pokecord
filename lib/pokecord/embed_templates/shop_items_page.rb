# frozen_string_literal: true

require 'discordrb'

require_relative '../../../db/connection'
require_relative '../../repositories/product_repo'

require_relative '../embed_templates'
require_relative '../../readable_number'

module Pokecord
  module EmbedTemplates
    class ShopItemsPage
      def initialize(page_number)
        @page_number = page_number
        @product_repo = Repositories::ProductRepo.new(
          Db::Connection.registered_container
        )
        @embed = Discordrb::Webhooks::Embed.new(
          color: Pokecord::EmbedTemplates::EMBED_COLOR,
          title: "Poke Shop | #{I18n.t("shop.#{page_number}.title")}",
          description: embed_description
        )
      end

      def to_embed
        product_repo.purchasable_products(page_number).each do |product|
          readable_price = ReadableNumber.stringify(product.price)
          embed.add_field(
            name: product.name,
            value: "#{readable_price} credits",
            inline: true
          )
        end
        embed
      end

      private

      attr_reader :page_number, :embed, :product_repo

      def embed_description
        I18n.t("shop.#{page_number}.description") +
          "\n\n" +
          I18n.t('shop.purchase_instructions')
      end
    end
  end
end
