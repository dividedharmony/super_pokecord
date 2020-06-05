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

%w{
  start
  pick
  pokemon
  order
  catch
  hint
  info
  catch
  pokedex
  nickname
  release
  mega
  shop
  fav
  addfav
  removefav
  select
  moves
  learn
  replace
  duel
  accept
  use
  confirm
  balance
  bal
  market
  trade
  p
  cancel
  daily
  silence
  redeem
  invite
  server
  patreon
  appeal
}.each do |command|
  bot.message(with_text: "p!#{command}") do |event|
    event.respond "The #{command} command has not been implemented yet. Check back soon for new features and updates!"
  end
end

bot.run
