# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/spawned_pokemon_repo'
require_relative '../pokecord/random_levels'

module Taskers
  class PopulateLevels
    def initialize(output = nil)
      @output = output || $stdout
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
      @randomizer = Pokecord::RandomLevels.new
    end

    def call
      output.puts "Beginning to populate levels..."
      level_0_spawns.each do |spawn|
        output.puts "Updating spawn #{spawn.id}"
        update_cmd = spawn_repo.spawned_pokemons.by_pk(spawn.id).command(:update)
        update_cmd.call(level: randomizer.rand_level)
      end
      output.puts "Finished populating levels!"
    end

    private

    attr_reader :output, :spawn_repo, :randomizer

    # level 0 pokemon have not been
    # properly leveled yet
    def level_0_spawns
      spawn_repo.spawned_pokemons.where(level: 0).to_a
    end
  end
end
