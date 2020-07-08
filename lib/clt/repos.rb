# frozen_string_literal: true

require 'forwardable'

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'
require_relative '../repositories/spawned_pokemon_repo'
require_relative '../repositories/evolution_repo'
require_relative '../repositories/user_repo'
require_relative '../repositories/product_repo'
require_relative '../repositories/fight_type_repo'
require_relative '../repositories/fight_event_repo'
require_relative '../repositories/inventory_item_repo'
require_relative '../repositories/trade_repo'

module CLT
  class Repos
    extend Forwardable

    def initialize
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @evolution_repo = Repositories::EvolutionRepo.new(
        Db::Connection.registered_container
      )
      @user_repo = Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
      @product_repo = Repositories::ProductRepo.new(
        Db::Connection.registered_container
      )
      @fight_type_repo = Repositories::FightTypeRepo.new(
        Db::Connection.registered_container
      )
      @fight_event_repo = Repositories::FightEventRepo.new(
        Db::Connection.registered_container
      )
      @inventory_repo = Repositories::InventoryItemRepo.new(
        Db::Connection.registered_container
      )
      @trade_repo = Repositories::TradeRepo.new(
        Db::Connection.registered_container
      )
    end

    attr_reader :spawn_repo,
                :pokemon_repo,
                :evolution_repo,
                :user_repo,
                :product_repo,
                :fight_type_repo,
                :fight_event_repo,
                :inventory_repo,
                :trade_repo

    def_delegators :spawn_repo, :spawned_pokemons
    def_delegators :pokemon_repo, :pokemons
    def_delegators :evolution_repo, :evolutions
    def_delegators :user_repo, :users
    def_delegators :product_repo, :products
    def_delegators :fight_type_repo, :fight_types
    def_delegators :fight_event_repo, :fight_events
    def_delegators :inventory_repo, :inventory_items
    def_delegators :trade_repo, :trades
  end
end
