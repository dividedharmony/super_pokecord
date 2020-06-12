# frozen_string_literal: true

require 'csv'
require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'

module Taskers
  class PopulatePokemonFromCsv
    def initialize(csv_location, output = nil)
      @output = output || $stdout
      @csv_rows = CSV.read(csv_location, headers: true)
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @time_of_creation = Time.now
    end

    def call
      output.puts 'Beginning to populate Pokemon...'
      csv_rows.each do |row|
        output.puts "Populating #{row.fetch('name')}"
        pokemon_repo.create(
          name: row.fetch('name').strip,
          pokedex_number: row.fetch('pokedex_number'),
          starter: !!(row.fetch('starter') =~ /x/),
          base_hp: row.fetch('base_hp'),
          base_attack: row.fetch('base_attack'),
          base_defense: row.fetch('base_defense'),
          base_sp_attack: row.fetch('base_sp_attack'),
          base_sp_defense: row.fetch('base_sp_defense'),
          base_speed: row.fetch('base_speed'),
          created_at: time_of_creation
        )
      end
      output.puts 'Finished populating Pokemon!'
    end

    private

    attr_reader :output, :csv_rows, :pokemon_repo, :time_of_creation
  end
end
