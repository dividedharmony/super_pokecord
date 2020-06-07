# frozen_string_literal: true

require 'dotenv/load'
require 'discordrb'

require_relative './lib/pokecord/wild_pokemon'
require_relative './lib/pokecord/commands/catch'
require_relative './lib/pokecord/commands/list_pokemons'

EMBED_COLOR = '#34d8eb'

bot = Discordrb::Commands::CommandBot.new(
  token: ENV["DISCORD_TOKEN"],
  prefix: 'p!'
)

if ENV['DEVELOPER_ID']
  bot.set_user_permission(ENV['DEVELOPER_ID'].to_i, 5)
end

bot.command :start do |event|
  starter_file = File.expand_path('assets/starters.png', File.dirname(__FILE__))
  event.send_file(File.open(starter_file, 'r'), caption: 'Pick your pokemon')
  "You can select one with `p!start [pokemon name]` (not implemented)"
end

bot.command(:wild, permission_level: 2) do |event|
  wild_pokemon = Pokecord::WildPokemon.new
  wild_pokemon.spawn!
  event.send_file(File.open(wild_pokemon.pic_file, 'r'), caption: "A wild Pokemon appeared! You can try to catch it with `p!catch` (not implemented)")
end

bot.command(:catch) do |event, name_guess|
  catch_cmd = Pokecord::Commands::Catch.new(event, name_guess)
  if catch_cmd.can_catch?
    if catch_cmd.name_correct?
      catch_cmd.catch!
      "Congratulations, #{event.user.mention}! You have successfully caught this Pokemon!"
    else
      'That is not the right Pokemon!'
    end
  end
end

bot.command(:pokemon) do |event, page_num|
  page_number = page_num || 0
  list_cmd = Pokecord::Commands::ListPokemons.new(
    event.user.id.to_s,
    page_number
  )
  event.channel.send_embed do |embed|
    embed.color = EMBED_COLOR
    embed.title = "Pokemon caught by #{event.user.name}"
    embed.description = list_cmd.to_a.map do |spawn|
      poke = spawn.pokemon
      "**#{poke.name}:** Pokedex number: #{poke.pokedex_number}, catch number: #{spawn.catch_number}"
    end.join("\n")
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(
      text: 'Displaying xxx out of xxx'
    )
  end
end

%w{
  pick
  order
  hint
  info
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

bot.command(:emily, permission_level: 2) do |event, page_num|
  page_number = page_num || 0
  list_cmd = Pokecord::Commands::ListPokemons.new(
    ENV['EMILY_ID'],
    page_number
  )
  event.channel.send_embed do |embed|
    embed.color = EMBED_COLOR
    embed.title = "Pokemon caught by Emily"
    embed.description = list_cmd.to_a.map do |spawn|
      poke = spawn.pokemon
      "**#{poke.name}:** Pokedex number: #{poke.pokedex_number}, catch number: #{spawn.catch_number}"
    end.join("\n")
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(
      text: 'Displaying xxx out of xxx'
    )
  end
end

bot.run
