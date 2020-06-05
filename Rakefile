# frozen_string_literal: true

require 'rom/sql/rake_task'

namespace :db do
  task :setup do
    require_relative './db/connection'
    ROM::SQL::RakeSupport.env = Db::Connection.container
  end
end
