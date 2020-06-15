source 'https://rubygems.org'
ruby File.read('.ruby-version', mode: 'rb').chomp

gem 'dotenv'
gem 'discordrb'
gem 'dry-monads'
gem 'i18n'
gem 'faker'

# database
gem 'rom'
gem 'rom-sql'
gem 'pg'
gem 'sequel_pg'

gem 'rake'

group :test do
  gem 'rspec'
  gem 'database_cleaner-sequel'
  gem 'rom-factory'
  gem 'timecop'
end

group :test, :development do
  gem 'pry', '~> 0.12.2'
end
