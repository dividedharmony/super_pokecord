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

bot.message(with_text: 'p!help') do |event|
  event.respond 'This is the Pokecord bot! It is currently under development, so not all commands may function properly. Check back soon for updates!'
end

bot.message(with_text: 'p!bye') do |event|
  event.respond 'Shutting down now'
end

bot.message(with_text: 'p!start') do |event|
  starter_file = File.expand_path('assets/starters.png', File.dirname(__FILE__))
  event.send_file(File.open(starter_file, 'r'), caption: 'Pick your pokemon')
end

bot.message(with_text: 'p!wild') do |event|
  random_pokedex_num = (rand(809) + 1).to_s.rjust(3, '0')
  pic_file = File.expand_path("pokemon_info/images/#{random_pokedex_num}.png", File.dirname(__FILE__))
  event.send_file(File.open(pic_file, 'r'), caption: 'A wild Pokemon appeared! You can try to catch it with `p!catch` (not implemented)')
end

bot.run
