# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_inventory_command'

module Pokecord
  module Commands
    class Hold < BaseInventoryCommand
      include Dry::Monads::Do.for(:call)

      def call
        user = yield get_user
        spawn = yield get_current_pokemon(user)
        product = yield get_product
        inventory_item = yield get_inventory_item(user, product)

        new_amount = inventory_item.amount - 1
        update_inventory_cmd = repos.
          inventory_items.
          by_pk(inventory_item.id).
          command(:update)
        update_inventory_cmd.call(amount: new_amount)
        repos.held_item_repo.create(
          spawned_pokemon_id: spawn.id,
          product_id: product.id,
          created_at: Time.now
        )
        pokemon_name = spawn.nickname.nil? ? spawn.pokemon.name : spawn.nickname
        Success(
          I18n.t(
            'hold.success',
            product_name: product.name,
            pokemon_name: pokemon_name
            )
          )
      end

      private

      def get_inventory_item(user, product)
        item = repos.
          inventory_items.
          where(user_id: user.id, product_id: product.id).
          first
        if item.nil? || item.amount < 1
          Failure(I18n.t('hold.insufficient_inventory', product_name: product.name))
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
