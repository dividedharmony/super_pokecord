# main.rb

require 'dotenv/load'
require 'discordrb'


bot = Discordrb::Bot.new(token: ENV["DISCORD_TOKEN"])

bot.run
