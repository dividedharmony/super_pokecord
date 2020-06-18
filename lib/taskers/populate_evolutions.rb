# frozen_string_literal: true

require 'csv'
require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'
require_relative '../repositories/product_repo'
require_relative '../repositories/evolution_repo'

module Taskers
  class PopulateEvolutions
    def initialize(csv_location, output = nil)
      @output = output || $stdout
      @csv_rows = CSV.read(csv_location, headers: true)
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @product_repo = Repositories::ProductRepo.new(
        Db::Connection.registered_container
      )
      @evolution_repo = Repositories::EvolutionRepo.new(
        Db::Connection.registered_container
      )
      @time_of_creation = Time.now
    end

    def call
      output.puts 'Beginning to populate evolutions...'
      csv_rows.each do |row|
        evolves_from = get_pokemon(row.fetch('evolves_from_pokedex_number').to_i)
        evolves_into = get_pokemon(row.fetch('evolves_into_pokedex_number').to_i)
        if evolves_from.id == evolves_into.id
          raise ArgumentError, "Error with #{evolves_from.name}! A Pokemon cannot evolve into itself!"
        end
        trigger_enum = row.fetch('trigger_enum').to_i
        level_requirement = row.fetch('level_requirement').to_i
        product_id = get_product_id(row.fetch('product'))
        prerequisites_enum = row.fetch('special_conditions')
        output.puts "Creating evolution of #{evolves_from.name} into #{evolves_into.name}"
        evolution_repo.create(
          evolves_from_id: evolves_from.id,
          evolves_into_id: evolves_into.id,
          trigger_enum: trigger_enum,
          level_requirement: level_requirement,
          product_id: product_id,
          prerequisites_enum: prerequisites_enum,
          created_at: time_of_creation
        )
      end
      output.puts 'Finished populating evolutions!'
    end

    private

    attr_reader :output, :csv_rows, :pokemon_repo, :product_repo, :evolution_repo, :time_of_creation

    def get_pokemon(pokedex_number)
      pokemon_repo.
        pokemons.
        where(pokedex_number: pokedex_number).
        one!
    end

    def get_product_id(product_name)
      return nil if product_name.nil? || product_name.length.zero?
      product = product_repo.products.where(name: actual_product_name(product_name)).one!
      product.id
    end

    def actual_product_name(name)
      case name.downcase
      when /fire/ then 'Fire Stone'
      when /water/ then 'Water Stone'
      when /leaf/ then 'Leaf Stone'
      when /thunder/ then 'Thunder Stone'
      when /moon/ then 'Moon Stone'
      when /sun/ then 'Sun Stone'
      when /shiny/ then 'Shiny Stone'
      when /dusk/ then 'Dusk Stone'
      when /dawn/ then 'Dawn Stone'
      when /ice/ then 'Ice Stone'
      when /oval/ then 'Oval Stone'
      when /friend/ then 'Friendship Bracelet'
      when /rock/ then "King's Rock"
      when /magnet/ then 'Powerful Magnet'
      when /coat/ then 'Metal Coat'
      when /protect/ then 'Protector'
      when /king's scale/ then "King's Scale"
      when /elect/ then 'Electirizer'
      when /magma/ then 'Magmarizer'
      when /upgrade/ then 'Upgrade'
      when /disc/ then 'Dubious Disc'
      when /fang/ then 'Razor Fang'
      when /prism/ then 'Prism Scale'
      when /reaper/ then 'Reaper Cloth'
      when /tooth/ then 'Deep Sea Tooth'
      when /sea scale/ then 'Deep Sea Scale'
      when /sachet/ then 'Sachet'
      when /dream/ then 'Whipped Dream'
      when /meltan/ then 'Meltan Candy'
      when /tart/ then 'Tart Apple'
      when /sweet apple/ then 'Sweet Apple'
      when /cracked/ then 'Cracked Pot'
      when /strawberry/ then 'Strawberry Sweet'
      else
        raise ArgumentError, "Unknown product name `#{name}`!"
      end
    end
  end
end
