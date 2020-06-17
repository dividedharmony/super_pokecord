# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/product_repo'

module Taskers
  class PopulateProducts
    def initialize(output = nil)
      @output = output || $stdout
      @product_repo = Repositories::ProductRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      output.puts "Beginning to populate products..."
      visible_product_names.each do |name|
        output.puts "Creating visible #{name} product"
        product_repo.create(name: name, visible: true)
      end
      invisible_product_names.each do |name|
        output.puts "Creating invisible #{name} product"
        product_repo.create(name: name, visible: false)
      end
      output.puts "Finished populating products!"
    end

    private

    attr_reader :output, :product_repo

    def visible_product_names
      [
        'Fire Stone',
        'Water Stone',
        'Thunder Stone',
        'Leaf Stone',
        'Moon Stone',
        'Sun Stone',
        'Shiny Stone',
        'Dusk Stone',
        'Dawn Stone',
        'Ice Stone',
        'Oval Stone',
        'Friendship Bracelet'
      ]
    end

    def invisible_product_names
      [
        "King's Rock",
        'Powerful Magnet',
        'Metal Coat',
        'Protector',
        "King's Scale",
        'Electirizer',
        'Magmarizer',
        'Upgrade',
        'Dubious Disc',
        'Razor Fang',
        'Prism Scale',
        'Reaper Cloth',
        'Deep Sea Tooth',
        'Deep Sea Scale',
        'Sachet',
        'Whipped Dream',
        'Meltan Candy',
        'Tart Apple',
        'Sweet Apple',
        'Cracked Pot',
        'Strawberry Sweet'
      ]
    end
  end
end
