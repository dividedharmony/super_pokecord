# frozen_string_literal: true

require_relative './repos'

module CLT
  class AddSpawn
    def initialize(discord_id = nil)
      @discord_id = discord_id || ENV['DEVELOPER_ID']
      @repos = CLT::Repos.new
      @user = repos.users.where(discord_id: @discord_id).one!
    end

    def add(pokedex_number, level = 1, required_exp = 250)
      pokemon = repos.pokemons.where(pokedex_number: pokedex_number).one!
      spawn = repos.spawn_repo.create(
        pokemon_id: pokemon.id,
        user_id: user.id,
        created_at: Time.now,
        caught_at: Time.now,
        catch_number: catch_number,
        level: level,
        required_exp: required_exp
      )
    end

    attr_reader :discord_id, :repos, :user

    def catch_number
      repos.spawn_repo.max_catch_number(user) + 1
    end
  end
end
