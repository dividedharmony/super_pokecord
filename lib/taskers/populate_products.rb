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
      product_attributes.each do |product_attr|
        existing_product = product_repo.products.where(name: product_attr[:name]).one
        if existing_product.nil?
          output.puts "Creating #{product_attr[:name]} product"
          product_repo.create(product_attr)
        else
          output.puts "Updating #{existing_product.name} product"
          product_attr.delete(:name)
          update_cmd = product_repo.products.by_pk(existing_product.id).command(:update)
          update_cmd.call(product_attr)
        end
      end
      output.puts "Finished populating products!"
    end

    private

    attr_reader :output, :product_repo

    def product_attributes
      [
        {
          name: 'Fire Stone',
          visible: true,
          price: 25_000,
          page_num: 1,
          position: 1
        },
        {
          name: 'Water Stone',
          visible: true,
          price: 25_000,
          page_num: 1,
          position: 2
        },
        {
          name: 'Thunder Stone',
          visible: true,
          price: 25_000,
          page_num: 1,
          position: 3
        },
        {
          name: 'Leaf Stone',
          visible: true,
          price: 25_000,
          page_num: 1,
          position: 4
        },
        {
          name: 'Moon Stone',
          visible: true,
          price: 25_000,
          page_num: 1,
          position: 5
        },
        {
          name: 'Sun Stone',
          visible: true,
          price: 32_000,
          page_num: 1,
          position: 6
        },
        {
          name: 'Shiny Stone',
          visible: true,
          price: 32_000,
          page_num: 1,
          position: 7
        },
        {
          name: 'Dusk Stone',
          visible: true,
          price: 32_000,
          page_num: 1,
          position: 8
        },
        {
          name: 'Dawn Stone',
          visible: true,
          price: 32_000,
          page_num: 1,
          position: 9
        },
        {
          name: 'Ice Stone',
          visible: true,
          price: 32_000,
          page_num: 1,
          position: 10
        },
        {
          name: 'Oval Stone',
          visible: true,
          price: 32_000,
          page_num: 1,
          position: 11
        },
        {
          name: 'Friendship Bracelet',
          visible: true,
          price: 40_000,
          page_num: 1,
          position: 12
        },
        {
          name: "King's Rock",
          visible: false,
          price: 60_000,
        },
        {
          name: 'Powerful Magnet',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Metal Coat',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Protector',
          visible: false,
          price: 60_000,
        },
        {
          name: "King's Scale",
          visible: false,
          price: 60_000,
        },
        {
          name: 'Electirizer',
          visible: false,
          price: 80_000,
        },
        {
          name: 'Magmarizer',
          visible: false,
          price: 80_000,
        },
        {
          name: 'Upgrade',
          visible: false,
          price: 70_000,
        },
        {
          name: 'Dubious Disc',
          visible: false,
          price: 70_000,
        },
        {
          name: 'Razor Fang',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Prism Scale',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Reaper Cloth',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Deep Sea Tooth',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Deep Sea Scale',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Sachet',
          visible: false,
          price: 60_000,
        },
        {
          name: 'Whipped Dream',
          visible: false,
          price: 50_000,
        },
        {
          name: 'Meltan Candy',
          visible: false,
          price: 70_000,
        },
        {
          name: 'Tart Apple',
          visible: false,
          price: 50_000,
        },
        {
          name: 'Sweet Apple',
          visible: false,
          price: 50_000,
        },
        {
          name: 'Cracked Pot',
          visible: false,
          price: 500,
        },
        {
          name: 'Strawberry Sweet',
          visible: false,
          price: 50_000,
        },
      ]
    end
  end
end
