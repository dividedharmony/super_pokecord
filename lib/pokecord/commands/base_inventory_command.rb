# frozen_string_literal: true

require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/product_repo'
require_relative '../../repositories/inventory_item_repo'

require_relative './base_user_command'

module Pokecord
  module Commands
    class BaseInventoryCommand < BaseUserCommand
      def initialize(discord_id, product_name)
        @product_name = product_name
        @product_repo = Repositories::ProductRepo.new(
          Db::Connection.registered_container
        )
        @inventory_repo = Repositories::InventoryItemRepo.new(
          Db::Connection.registered_container
        )
        super(discord_id)
      end

      def call
        raise NotImplementedError, "#{self.class.name} needs to implment the #call method"
      end

      def get_product
        local_name_var = product_name
        products = product_repo.products.where { visible.is(true) & name.ilike(local_name_var) }
        if products.to_a.none?
          Failure(I18n.t('buy.no_such_product', product_name: product_name))
        else
          Success(products.first)
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

      private

      attr_reader :product_name, :product_repo, :inventory_repo
    end
  end
end
