# frozen_string_literal: true

require 'dotenv/load'
require 'discordrb'

require_relative './lib/pokecord/wild_pokemon'
require_relative './lib/pokecord/commands/catch'
require_relative './lib/pokecord/commands/select'
require_relative './lib/pokecord/commands/info'
require_relative './lib/pokecord/commands/nickname'
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

bot.command(:catch) do |event, *args|
  if args.length.zero?
    'Correct usage of this command is `p!catch [pokemon name]`. A wild Pokemon must be present in order for you to catch one.'
  else
    name_guess = args.join(' ')
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
end

bot.command(:pokemon) do |event, given_page_num|
  one_indexed_page_num = given_page_num&.to_i || 1
  actual_page_num = one_indexed_page_num - 1
  list_cmd = Pokecord::Commands::ListPokemons.new(
    event.user.id.to_s,
    actual_page_num
  )
  pokemons = list_cmd.to_a
  if pokemons.length > 0
    event.channel.send_embed do |embed|
      embed.color = EMBED_COLOR
      embed.title = "Pokemon caught by #{event.user.name}"
      embed.description = pokemons.map do |spawn|
        poke = spawn.pokemon
        "**#{poke.name}** ---> nickname: #{spawn.nickname}, Pokedex number: #{poke.pokedex_number}, catch number: #{spawn.catch_number}"
      end.join("\n")
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(
        text: "Displaying page #{one_indexed_page_num} of #{list_cmd.total_pages}"
      )
    end
  else
    "You do not have any Pokemon! Try to catch some with the `p!catch` command."
  end
end

# TODO allow user to select on nickname or pokemon name
bot.command(:select) do |event, catch_number|
  if catch_number.nil? || catch_number !~ /\A\d+\z/
    'Correct usage of this command is `p!select [catch number]`'
  else
    select_cmd = Pokecord::Commands::Select.new(event.user.id.to_s, catch_number.to_i)
    if select_cmd.valid_number?
      spawned_poke = select_cmd.call
      "#{event.user.mention}, you have selected your #{spawned_poke.pokemon.name}"
    else
      'Sorry, you do not have a Pokemon with that catch number.'
    end
  end
end

bot.command(:info) do |event|
  info_cmd = Pokecord::Commands::Info.new(event.user.id.to_s)
  poke_spawn = info_cmd.call
  if poke_spawn.nil?
    "You do not have a Pokemon selected to see its info. Use `p!pokemon` to view all your Pokemon and `p!select` to choose which one you want to name."
  else
    poke_ideal = poke_spawn.pokemon
    pokedex_display = poke_ideal.pokedex_number.to_s.rjust(3, '0')
    event.channel.send_embed do |embed|
      embed.color = EMBED_COLOR
      embed.title = "#{event.user.name}'s #{poke_spawn.nickname || poke_ideal.name}"
      embed.description = "Level xxx #{poke_ideal.name}"
      embed.add_field(name: 'Pokedex No.', value: pokedex_display)
      embed.add_field(name: 'HP', value: poke_ideal.base_hp)
      embed.add_field(name: 'Attack', value: poke_ideal.base_attack)
      embed.add_field(name: 'Defense', value: poke_ideal.base_defense)
      embed.add_field(name: 'Sp. Attack', value: poke_ideal.base_sp_attack)
      embed.add_field(name: 'Sp. Defense', value: poke_ideal.base_sp_defense)
      embed.add_field(name: 'Speed', value: poke_ideal.base_speed)
      embed.add_field(name: 'Caught At', value: poke_spawn.caught_at.strftime('%Y-%m-%d'))
    end
    event.send_file(
      File.open(
        File.expand_path(
          "./pokemon_info/images/#{pokedex_display}.png", File.dirname(__FILE__)
        ),
        'r'
      )
    )
  end
end

bot.command(:nickname) do |event, *words|
  if words.length.zero?
    'Correct usage of this command is `p!nickname [one or more words]`.'
  else
    nickname = words.join(' ')
    nickname_cmd = Pokecord::Commands::Nickname.new(event.user.id.to_s, nickname)
    if nickname_cmd.no_pokemon_to_name?
      "You do not have a Pokemon selected to nickname. Use `p!pokemon` to view all your Pokemon and `p!select` to choose which one you want to name."
    elsif nickname_cmd.nickname_taken?
      "You already have a Pokemon named **#{nickname}**! You cannot use a nickname for more than one Pokemon."
    else
      spawn = nickname_cmd.call
      "#{event.user.mention}, you have successfully named your Pokemon \"**#{spawn.nickname}**\""
    end
  end
end

%w{
  pick
  order
  hint
  pokedex
  shop
  release
  mega
  shop
  fav
  addfav
  removefav
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

bot.command(:emily, permission_level: 2) do |event, given_page_num|
  one_indexed_page_num = given_page_num || 1
  actual_page_num = one_indexed_page_num - 1
  list_cmd = Pokecord::Commands::ListPokemons.new(
    ENV['EMILY_ID'],
    actual_page_num
  )
  event.channel.send_embed do |embed|
    embed.color = EMBED_COLOR
    embed.title = "Pokemon caught by Emily Harmon"
    embed.description = list_cmd.to_a.map do |spawn|
      poke = spawn.pokemon
      "**#{poke.name}:** Pokedex number: #{poke.pokedex_number}, catch number: #{spawn.catch_number}"
    end.join("\n")
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(
      text: "Displaying page #{one_indexed_page_num} of #{list_cmd.total_pages}"
    )
  end
end

bot.run
