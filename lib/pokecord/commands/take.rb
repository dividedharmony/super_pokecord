# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_inventory_command'

module Pokecord
  module Commands
    class Take < BaseInventoryCommand
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id)
        super(discord_id, nil)
      end

      def call
        user = yield get_user
        spawn = yield get_current_pokemon(user)
        held_item = yield get_held_item(spawn)
        inventory_item = find_or_create_inventory_item(user, held_item.product)

        new_amount = inventory_item.amount + 1
        update_inventory_cmd = repos.
          inventory_items.
          by_pk(inventory_item.id).
          command(:update)
        update_inventory_cmd.call(amount: new_amount)
        repos.
          held_items.
          by_pk(held_item.id).
          command(:delete).
          call

        pokemon_name = spawn.nickname.nil? ? spawn.pokemon.name : spawn.nickname
        Success(
          I18n.t(
            'take.success',
            product_name: held_item.product.name,
            pokemon_name: pokemon_name
            )
          )
      end

      private

      def get_held_item(spawn)
        held_item = repos.
          held_items.
          combine(:product).
          where(spawned_pokemon_id: spawn.id).
          first
        if held_item.nil?
          Failure(I18n.t('take.pokemon_is_not_holding_an_item'))
        else
          Success(held_item)
        end
      end

      def only_visible_products
        false
      end
    end
  end
end
