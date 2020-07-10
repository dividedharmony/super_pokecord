# frozen_string_literal: true

require 'dry/monads/do'

require_relative './base_inventory_command'
require_relative '../evolve'

module Pokecord
  module Commands
    class Use < BaseInventoryCommand
      EvolutionPayload = Struct.new(:spawned_pokemon, :evolved_from, :evolved_into)

      include Dry::Monads::Do.for(:call)

      # initialize defined by parent class

      def call
        user = yield get_user
        product = yield get_product
        inventory_item = yield get_item(user, product)
        spawn = yield get_spawn(user)
        evolved_from = spawn.pokemon

        evolve_result = Pokecord::Evolve.new(spawn, :item, inventory_item).call
        if evolve_result.success?
          evolved_into = evolve_result.value!
          update_cmd = repos.inventory_items.by_pk(inventory_item.id).command(:update)
          update_cmd.call(amount: (inventory_item.amount - 1), updated_at: Time.now)
          Success(
            EvolutionPayload.new(spawn, evolved_from, evolved_into)
          )
        else
          Failure(I18n.t('use_item.cannot_use_item', product_name: product.name))
        end
      end

      private

      def only_visible_products
        false
      end

      def get_spawn(user)
        if user.current_pokemon_id.nil?
          Failure(I18n.t('needs_a_current_pokemon'))
        else
          spawned_pokemon = repos.
            spawned_pokemons.
            combine(:pokemon).
            where(id: user.current_pokemon_id).
            first
          spawned_pokemon.nil? ?
            Failure(I18n.t('needs_a_current_pokemon')) :
            Success(spawned_pokemon)
        end
      end

      def get_item(user, product)
        item = repos.
          inventory_items.
          where(user_id: user.id, product_id: product.id).
          first
        if item.nil? || item.amount <= 0
          Failure(I18n.t('use_item.no_such_item', product_name: product.name))
        else
          Success(item)
        end
      end
    end
  end
end
