# frozen_string_literal: true

require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/product_repo'
require_relative '../../repositories/inventory_item_repo'

require_relative './base_user_command'

module Pokecord
  module Commands
    class Buy < BaseUserCommand
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id, product_name, purchase_amount)
        @product_name = product_name
        @purchase_amount = purchase_amount
        @product_repo = Repositories::ProductRepo.new(
          Db::Connection.registered_container
        )
        @inventory_repo = Repositories::InventoryItemRepo.new(
          Db::Connection.registered_container
        )
        super(discord_id)
      end

      def call
        user = yield get_user
        product = yield get_product
        yield validate_can_purchase(user, product)

        inventory_item = find_or_create_inventory_item(user, product)
        new_total = inventory_item.amount + purchase_amount
        update_cmd = inventory_repo.inventory_items.by_pk(inventory_item.id).command(:update)
        update_cmd.call(amount: new_total, updated_at: Time.now)
        Success(I18n.t('buy.success', amount: purchase_amount, product_name: product.name))
      end

      private

      attr_reader :product_name, :purchase_amount, :product_repo, :inventory_repo

      def get_product
        local_name_var = product_name
        products = product_repo.products.where { visible.is(true) & name.ilike(local_name_var) }
        if products.to_a.none?
          Failure(I18n.t('buy.no_such_product', product_name: product_name))
        else
          Success(products.first)
        end
      end

      def validate_can_purchase(user, product)
        if purchase_amount < 1
          Failure(I18n.t('buy.amount_must_be_greater_than_zero', amount: purchase_amount))
        elsif user.current_balance < (purchase_amount * product.price)
          Failure(I18n.t('buy.insufficient_funds', amount: purchase_amount, product_name: product.name))
        else
          Success(product)
        end
      end

      def find_or_create_inventory_item(user, product)
        item = inventory_repo.inventory_items.where(user_id: user.id, product_id: product.id).first
        item || inventory_repo.create(
          user_id: user.id,
          product_id: product.id,
          created_at: Time.now,
          updated_at: Time.now
        )
      end
    end
  end
end
