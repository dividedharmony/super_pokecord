# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_user_command'

module Pokecord
  module Commands
    class ListInventory < BaseUserCommand
      InventoryPayload = Struct.new(:user, :inventory_items)

      include Dry::Monads::Do.for(:call)

      # initialize is defined by BaseUserCommand

      def call
        user = yield get_user

        inventory_items = visible_inventory.where(user_id: user.id).to_a
        if inventory_items.none?
          Failure(I18n.t('inventory.no_items'))
        else
          Success(inventory_items)
        end
      end

      private

      attr_reader :inventory_repo

      def visible_inventory
        repos.
          inventory_items.
          combine(:product).
          where { amount > 0 }
      end
    end
  end
end
