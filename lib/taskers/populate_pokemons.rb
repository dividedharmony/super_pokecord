# frozen_string_literal: true

require 'json'
require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'

module Taskers
  class PopulatePokemons
    def initialize
      @poke_repo = Repositories::PokemonRepo.new(Db::Connection.registered_container)
      @time_of_creation = Time.now
    end

    def call
      return already_populated_message if poke_repo.pokemons.count > 0

      poke_info_path = File.expand_path(
        '../../pokemon_info/pokedex.json',
        File.dirname(__FILE__)
      )
      poke_info = JSON.parse(IO.read(poke_info_path))

      $stdout.puts "Beginning to populate..."
      poke_info.each do |pokedex_entry|
        $stdout.puts "Creating entry for #{pokedex_entry['name']['english']}"

        poke_repo.create(
          pokedex_number: pokedex_entry['id'],
          name: pokedex_entry['name']['english'],
          base_hp: pokedex_entry['base']['HP'],
          base_attack: pokedex_entry['base']['Attack'],
          base_defense: pokedex_entry['base']['Defense'],
          base_sp_attack: pokedex_entry['base']['Sp. Attack'],
          base_sp_defense: pokedex_entry['base']['Sp. Defense'],
          base_speed: pokedex_entry['base']['Speed'],
          created_at: time_of_creation
        )
      end

      $stdout.puts "Population task complete!"
    end

    private

    attr_reader :poke_repo, :time_of_creation

    def already_populated_message
      $stdout.puts "The Pokemon table has already been populated for this database"
    end
  end
end
