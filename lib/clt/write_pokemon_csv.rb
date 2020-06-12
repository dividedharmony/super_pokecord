# frozen_string_literal: true

require 'csv'
require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'

module CLT
  class WritePokemonCsv
    HEADERS = [
      :pokedex_number,
      :name,
      :starter,
      :rarity_enum
    ].freeze

    def initialize(file_location)
      @file_location = file_location
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      CSV.open(file_location, 'wb') do |csv|
        csv << HEADERS
        pokemon_repo.pokemons.to_a.each do |pokemon|
          csv << pokemon_row(pokemon)
        end
      end
    end

    private

    attr_reader :file_location, :pokemon_repo

    def pokemon_row(pokemon)
      HEADERS.map do |attribute|
        pokemon[attribute]
      end
    end
  end
end
