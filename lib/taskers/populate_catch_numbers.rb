# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/user_repo'
require_relative '../repositories/spawned_pokemon_repo'

module Taskers
  class PopulateCatchNumbers
    def initialize
      @user_repo = Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
      @spawn_repo = Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
      @users = user_repo.users.to_a
    end

    def call
      $stdout.puts "Beginning to populate catch numbers..."
      users.each do |user|
        $stdout.puts "Populating for user #{user.id}"
        current_number = spawn_repo.max_catch_number(user)
        un_numbered_spawns(user).each do |spawn|
          current_number += 1
          update_cmd = spawn_repo.
            spawned_pokemons.
            by_pk(spawn.id).
            command(:update)

          $stdout.puts "\tPopulating catch number #{current_number}"
          update_cmd.call(catch_number: current_number)
        end
      end
      $stdout.puts "Finished populating catch numbers!!"
    end

    private

    attr_reader :user_repo, :spawn_repo, :users

    def un_numbered_spawns(user)
      spawn_repo.
        spawned_pokemons.
        where(user_id: user.id, catch_number: nil).
        to_a
    end
  end
end
