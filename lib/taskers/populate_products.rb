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
        },
        {
          name: 'Powerful Magnet',
          visible: false,
        },
        {
          name: 'Metal Coat',
          visible: false,
        },
        {
          name: 'Protector',
          visible: false,
        },
        {
          name: "King's Scale",
          visible: false,
        },
        {
          name: 'Electirizer',
          visible: false,
        },
        {
          name: 'Magmarizer',
          visible: false,
        },
        {
          name: 'Upgrade',
          visible: false,
        },
        {
          name: 'Dubious Disc',
          visible: false,
        },
        {
          name: 'Razor Fang',
          visible: false,
        },
        {
          name: 'Prism Scale',
          visible: false,
        },
        {
          name: 'Reaper Cloth',
          visible: false,
        },
        {
          name: 'Deep Sea Tooth',
          visible: false,
        },
        {
          name: 'Deep Sea Scale',
          visible: false,
        },
        {
          name: 'Sachet',
          visible: false,
        },
        {
          name: 'Whipped Dream',
          visible: false,
        },
        {
          name: 'Meltan Candy',
          visible: false,
        },
        {
          name: 'Tart Apple',
          visible: false,
        },
        {
          name: 'Sweet Apple',
          visible: false,
        },
        {
          name: 'Cracked Pot',
          visible: false,
        },
        {
          name: 'Strawberry Sweet',
          visible: false,
        },
      ]
    end
  end
end
