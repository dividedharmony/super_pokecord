# frozen_string_literal: true

require 'rom/sql/rake_task'

namespace :db do
  task :setup do
    require_relative './db/connection'
    ROM::SQL::RakeSupport.env = Db::Connection.container
  end
end

namespace :pokecord do
  task :populate_pokemon do
    require_relative './lib/taskers/populate_pokemons'
    Taskers::PopulatePokemons.new.call
  end

  task :populate_catch_numbers do
    require_relative './lib/taskers/populate_catch_numbers'
    Taskers::PopulateCatchNumbers.new.call
  end

  task :populate_starters do
    require_relative './lib/taskers/populate_starters'
    Taskers::PopulateStarters.new.call
  end
end
