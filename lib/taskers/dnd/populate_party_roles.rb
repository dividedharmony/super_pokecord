# frozen_string_literal: true

require_relative '../../../db/connection'
require_relative '../../repositories/party_role_repo'

module Taskers
  module Dnd
    class PopulatePartyRoles
      def initialize(output = nil)
        @output = output || $stdout
        @role_repo = Repositories::PartyRoleRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        output.puts 'Beginning to populate party roles...'
        primary_roles.each do |role_name|
          output.puts "Adding #{role_name} primary role"
          role_repo.create(name: role_name, primary_role: true)
        end
        secondary_roles.each do |role_name|
          output.puts "Adding #{role_name} secondary role"
          role_repo.create(name: role_name, primary_role: false)
        end
        output.puts 'Finished populating party roles!'
      end

      private

      attr_reader :output, :role_repo

      def primary_roles
        [
          'Tank',
          'Healer',
          'Arcane',
          'Damage'
        ]
      end

      def secondary_roles
        [
          'Athletics',
          'Arcana',
          'Investigation',
          'Perception',
          'Persuasion',
          'Stealth'
        ]
      end
    end
  end
end
