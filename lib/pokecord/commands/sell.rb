# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_inventory_command'

module Pokecord
  module Commands
    class Sell < BaseInventoryCommand
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, product_name, sell_amount)
        @sell_amount = sell_amount
        super(discord_id, product_name)
      end

      def call
        user = yield get_user
        product = yield get_product
        inventory_item = yield get_inventory_item(user, product)

        new_amount = inventory_item.amount - sell_amount
        update_item_cmd = inventory_repo.inventory_items.by_pk(inventory_item.id).command(:update)
        update_item_cmd.call(amount: new_amount)
        currency_award = (inventory_item.product.price / 2) * sell_amount
        update_user_cmd = user_repo.users.by_pk(user.id).command(:update)
        update_user_cmd.call(current_balance: user.current_balance + currency_award)
        Success(
          I18n.t(
            'sell.success',
            sell_amount: sell_amount,
            product_name: product.name,
            currency_award: currency_award
            )
          )
      end

      private

      attr_reader :sell_amount

      def get_inventory_item(user, product)
        item = inventory_repo.
          inventory_items.
          combine(:product).
          where(user_id: user.id, product_id: product.id).
          first
        if item.nil? || item.amount < sell_amount
          Failure(I18n.t('sell.insufficient_inventory', sell_amount: sell_amount, product_name: product.name))
        else
          Success(item)
        end
      end

      def only_visible_products
        false
      end
    end
  end
end
