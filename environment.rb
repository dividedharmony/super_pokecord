# frozen_string_literal: true

class Environment
  class << self
    def development?
      ENV['ENVIRONMENT'].nil? ? true : ENV['ENVIRONMENT'] == 'development'
    end

    def production?
      ENV['ENVIRONMENT'] == 'production'
    end
  end
end
