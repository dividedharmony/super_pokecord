# main.rb

require 'dotenv/load'
require 'discordrb'

bot = Discordrb::Commands::CommandBot.new(
  token: ENV["DISCORD_TOKEN"],
  prefix: 'p!'
)

bot.command :start do |event|
  starter_file = File.expand_path('assets/starters.png', File.dirname(__FILE__))
  event.send_file(File.open(starter_file, 'r'), caption: 'Pick your pokemon')
  "You can select one with `p!start [pokemon name]` (not implemented)"
end

bot.command :wild do |event|
  random_pokedex_num = (rand(809) + 1).to_s.rjust(3, '0')
  pic_file = File.expand_path("pokemon_info/images/#{random_pokedex_num}.png", File.dirname(__FILE__))
  event.send_file(File.open(pic_file, 'r'), caption: 'A wild Pokemon appeared! You can try to catch it with `p!catch` (not implemented)')
end

%w{
  pick
  pokemon
  order
  hint
  info
  catch
  pokedex
  shop
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
}.each do |cmd|
  bot.command cmd.to_sym do |event|
    "The #{cmd} command has not been implemented yet. Check back soon for new features and updates!"
  end
end

bot.run
