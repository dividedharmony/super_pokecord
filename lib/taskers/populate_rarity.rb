# frozen_string_literal: true

require 'csv'
require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'

module Taskers
  class PopulateRarity
    def initialize(csv_location, output = nil)
      @output = output || $stdout
      @csv_rows = CSV.read(csv_location, headers: true)
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      output.puts 'Beginning to populate Pokemon rarity...'
      csv_rows.each do |row|
        rarity_enum = row['rarity_enum'].to_i
        pokemon = pokemon_repo.pokemons.where(pokedex_number: row['pokedex_number']).one!
        output.puts "Updating #{pokemon.name}'s rarity"
        update_cmd = pokemon_repo.pokemons.by_pk(pokemon.id).command(:update)
        update_cmd.call(rarity_enum: rarity_enum)
      end
      output.puts 'Finished populating Pokemon rarity!'
    end

    private

    attr_reader :output, :csv_rows, :pokemon_repo
  end
end
