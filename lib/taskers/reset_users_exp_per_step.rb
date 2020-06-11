# frozen_string_literal: true

require_relative '../../db/connection'
require_relative '../repositories/user_repo'

require_relative '../pokecord/exp_curve'

module Taskers
  class ResetUsersExpPerStep
    def initialize(output = nil)
      @output = output || $stdout
      @user_repo = Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
      @standard_exp = Pokecord::ExpCurve::EXP_PER_STEP
    end

    def call
      output.puts 'Beginning to reset users exp_per_step...'
      users_with_nonstandard_exp.each do |user|
        output.puts "Updating user #{user.id}"
        update_cmd = user_repo.users.by_pk(user.id).command(:update)
        update_cmd.call(exp_per_step: standard_exp)
      end
      output.puts 'Finished reseting users exp_per_step!'
    end

    private

    def users_with_nonstandard_exp
      user_repo.users.where { exp_per_step.not(Pokecord::ExpCurve::EXP_PER_STEP) }.to_a
    end

    attr_reader :output, :user_repo, :standard_exp
  end
end
