# main.rb

require 'dotenv/load'
require 'discordrb'

bot = Discordrb::Commands::CommandBot.new(
  token: ENV["DISCORD_TOKEN"],
  prefix: 'p!'
)

bot.command :plus do |event, x, y|
  "The sum of #{x} and #{y} is #{x.to_i + y.to_i}"
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
