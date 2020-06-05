# main.rb

require 'dotenv/load'
require 'discordrb'


bot = Discordrb::Bot.new(token: ENV["DISCORD_TOKEN"])

bot.message(with_text: 'p!life') do |event|
  event.respond 'The answer to life, the universe, and everything is 42. Sorry, what was the question again?'
end

bot.message(with_text: 'p!ping') do |event|
  event.respond 'PONG'
end

bot.message(with_text: 'p!bye') do |event|
  event.respond 'Shutting down now'
end

bot.run
