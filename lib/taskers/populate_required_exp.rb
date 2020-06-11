# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/spawned_pokemon_repo'
require_relative '../pokecord/exp_curve'

module Taskers
  class PopulateRequiredExp
    def initialize(output = nil)
      @output = output || $stdout
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end

    def call
      output.puts 'Beginning to populate required_exp...'
      pokemon_without_required_exp.each do |spawn|
        required_exp = Pokecord::ExpCurve.new(spawn.level).required_exp_for_next_level
        next if required_exp.zero?
        output.puts "setting pokemon #{spawn.id} to #{required_exp} required exp"
        update_cmd = spawn_repo.spawned_pokemons.by_pk(spawn.id).command(:update)
        update_cmd.call(required_exp: required_exp)
      end
      output.puts 'Finished populating required_exp!'
    end

    private

    attr_reader :output, :spawn_repo

    def pokemon_without_required_exp
      spawn_repo.spawned_pokemons.where(required_exp: 0).to_a
    end
  end
end
