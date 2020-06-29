# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require_relative '../../../db/connection'
require_relative '../../repositories/party_role_repo'

module Dnd
  module Commands
    class AssignPartyRole
      RolePayload = Struct.new(:primary, :secondary)

      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(discord_id)
        @discord_id = discord_id
        @user_repo = Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
        @role_repo = Repositories::PartyRoleRepo.new(
          Db::Connection.registered_container
        )
      end

      def call
        user = find_or_create_user
        yield validate_user(user)
        primary_role = get_role(true)
        secondary_role = get_role(false)

        update_cmd = user_repo.users.by_pk(user.id).command(:update)
        update_cmd.call(
          primary_role_id: primary_role.id,
          secondary_role_id: secondary_role.id
        )
        Success(RolePayload.new(primary_role, secondary_role))
      end

      private

      attr_reader :discord_id, :user_repo, :role_repo

      def find_or_create_user
        existing_user = user_repo.users.where(discord_id: discord_id).one
        existing_user || user_repo.create(
          discord_id: discord_id,
          exp_per_step: Pokecord::ExpCurve::EXP_PER_STEP,
          created_at: Time.now
        )
      end

      def validate_user(user)
        if user.primary_role_id && user.secondary_role_id
          Failure('You already have an assigned role!')
        else
          Success(user)
        end
      end

      def get_role(is_primary)
        possible_roles = roles_less_than_max(is_primary)
        possible_roles.any? ? possible_roles.sample : all_roles(is_primary).sample
      end

      def roles_less_than_max(is_primary)
        if is_primary
          roles = role_repo.party_roles.combine(:primary_users).where(primary_role: true).to_a
          max_num = roles.max_by { |role| role.primary_users.count }.primary_users.count
          roles.select { |role| role.primary_users.count < max_num }
        else
          roles = role_repo.party_roles.combine(:secondary_users).where(primary_role: false).to_a
          max_num = roles.max_by { |role| role.secondary_users.count }.secondary_users.count
          roles.select { |role| role.secondary_users.count < max_num }
        end
      end

      def all_roles(is_primary)
        role_repo.party_roles.where(primary_role: is_primary).to_a
      end
    end
  end
end
