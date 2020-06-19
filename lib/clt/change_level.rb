# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/pokemon_repo'
require_relative '../repositories/user_repo'
require_relative '../repositories/spawned_pokemon_repo'

module CLT
  class ChangeLevel
    def initialize(discord_id = nil)
      @discord_id = discord_id || ENV['DEVELOPER_ID']
      @pokemon_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @user_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @spawn_repo = Repositories::PokemonRepo.new(
        Db::Connection.registered_container
      )
      @spawns = nil
    end

    def set_spawns(pokedex_number)
      pokemon = pokemon_repo.pokemons.where(pokedex_number: pokedex_number).one!
      @spawns = spawn_repo.spawned_pokemons.where(pokemon_id: pokemon.id).to_a
    end

    def set_level(level_num)
      @spawns = spawns.map do |spawn|
        update_cmd = spawn_repo.spawned_pokemons.by_pk(spawn.id).command(:update)
        update_cmd.call(level: level_num)
      end
    end

    attr_accessor :discord_id, :pokemon_repo, :user_repo, :spawn_repo, :spawns

    private

    def user
      @_user ||= user_repo.users.where(discord_id: discord_id)
    end
  end
end
