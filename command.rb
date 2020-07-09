# frozen_string_literal: true

require 'dotenv/load'
require 'discordrb'
require 'i18n'

require_relative './lib/pokecord/wild_pokemon'
require_relative './lib/pokecord/starter_pokemons'
require_relative './lib/pokecord/commands/pick'
require_relative './lib/pokecord/commands/catch'
require_relative './lib/pokecord/commands/select'
require_relative './lib/pokecord/commands/info'
require_relative './lib/pokecord/commands/nickname'
require_relative './lib/pokecord/commands/name_rival'
require_relative './lib/pokecord/commands/fight'
require_relative './lib/pokecord/commands/initiate_trade'
require_relative './lib/pokecord/commands/accept_trade'
require_relative './lib/pokecord/commands/modify_trade'
require_relative './lib/pokecord/commands/confirm_trade'
require_relative './lib/pokecord/commands/execute_trade'
require_relative './lib/pokecord/commands/list_pokemons'
require_relative './lib/pokecord/commands/alter_fav'
require_relative './lib/pokecord/commands/balance'
require_relative './lib/pokecord/commands/buy'
require_relative './lib/pokecord/commands/list_inventory'
require_relative './lib/pokecord/commands/use'
# dnd commands
require_relative './lib/dnd/commands/assign_party_role'
# admin commands
require_relative './lib/pokecord/commands/admin/reset_balances'
# embed templates
require_relative './lib/pokecord/embed_templates/trade'
require_relative './lib/pokecord/embed_templates/shop_landing_page'
require_relative './lib/pokecord/embed_templates/shop_items_page'
require_relative './lib/pokecord/embed_templates/inventory_list'
require_relative './lib/pokecord/embed_templates/spawn_list'

require_relative './lib/callbacks/update_trade'

I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
I18n.default_locale = :en

bot = Discordrb::Commands::CommandBot.new(
  token: ENV["DISCORD_TOKEN"],
  prefix: 'p!'
)

if ENV['DEVELOPER_ID']
  bot.set_user_permission(ENV['DEVELOPER_ID'].to_i, 5)
end

bot.command :start do |event|
  event.channel.send_embed do |embed|
    embed.color = Pokecord::EmbedTemplates::EMBED_COLOR
    embed.title = 'Welcome to Pokecord'
    embed.description = <<~DESC
      This is a Discord bot that
      allows users to catch, trade,
      and train Pokemon! First,
      you need a starter Pokemon.
      Pick one of the following
      starters with the command
      `p!pick [pokemon name]`
    DESC
    Pokecord::StarterPokemons.new.to_h.each do |region, pokemons|
      poke_names = pokemons.map { |poke| poke.name }.join(', ')
      embed.add_field(name: region, value: poke_names)
    end
  end
  starter_file = File.expand_path('assets/starter_heart.jpg', File.dirname(__FILE__))
  event.send_file(File.open(starter_file, 'r'), caption: 'Pick your pokemon')
end

bot.command(:pick) do |event, *args|
  if args.length.zero?
    "Correct usage of this command is `p!pick [name of a starter pokemon]`."
  else
    poke_name = args.join(' ').capitalize
    pick_cmd = Pokecord::Commands::Pick.new(event.user.id.to_s, poke_name)
    if pick_cmd.already_picked_starter?
      "You have already picked a starter Pokemon!"
    elsif pick_cmd.name_incorrect?
      "Could not find a Pokemon with the name \"#{poke_name}\""
    elsif pick_cmd.is_not_starter?
      "Unfortunately, #{poke_name} is not a starter Pokemon. Please select a different Pokemon from the `p!start` list."
    else
      picked_pokemon = pick_cmd.call
      "Congratulations, #{event.user.mention}! You have successfully picked a #{picked_pokemon.name} as your starting Pokemon!"
    end
  end
end

bot.command(:catch) do |event, *args|
  if args.length.zero?
    'Correct usage of this command is `p!catch [pokemon name]`. A wild Pokemon must be present in order for you to catch one.'
  else
    name_guess = args.join(' ')
    catch_cmd = Pokecord::Commands::Catch.new(event, name_guess)
    if catch_cmd.can_catch?
      if catch_cmd.name_correct?
        poke_spawn = catch_cmd.catch!
        "Congratulations, #{event.user.mention}! You have successfully caught a level #{poke_spawn.level} **#{poke_spawn.pokemon.name}**!"
      else
        'That is not the right Pokemon!'
      end
    end
  end
end

bot.command(:pokemon) do |event, given_page_num|
  one_indexed_page_num = given_page_num&.to_i || 1
  actual_page_num = one_indexed_page_num - 1
  list_result = Pokecord::Commands::ListPokemons.new(
    event.user.id.to_s,
    actual_page_num
  ).call
  if list_result.success?
    list_payload = list_result.value!
    embed = Pokecord::EmbedTemplates::SpawnList.new(event.user.name, list_payload).to_embed
    event.channel.send_embed('', embed)
    nil
  else
    list_result.failure
  end
end

bot.command(:addfav) do |event, catch_number|
  if catch_number.nil? || catch_number.to_i.zero?
    I18n.t('alter_fav.add_argument_error')
  else
    alter_result = Pokecord::Commands::AlterFav.new(
      event.user.id.to_s,
      catch_number,
      true
    )
    alter_result.success? ? alter_result.value! : alter_result.failure
  end
end

bot.command(:removefav) do |event, catch_number|
  if catch_number.nil? || catch_number.to_i.zero?
    I18n.t('alter_fav.remove_argument_error')
  else
    alter_result = Pokecord::Commands::AlterFav.new(
      event.user.id.to_s,
      catch_number,
      false
    )
    alter_result.success? ? alter_result.value! : alter_result.failure
  end
end

bot.command(:fav) do |event, given_page_num|
  one_indexed_page_num = given_page_num&.to_i || 1
  actual_page_num = one_indexed_page_num - 1
  list_result = Pokecord::Commands::ListPokemons.new(
    event.user.id.to_s,
    actual_page_num,
    true
  ).call
  if list_result.success?
    list_payload = list_result.value!
    embed = Pokecord::EmbedTemplates::SpawnList.new(event.user.name, list_payload).to_embed
    event.channel.send_embed('', embed)
    nil
  else
    list_result.failure
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
      embed.color = Pokecord::EmbedTemplates::EMBED_COLOR
      embed.title = "#{event.user.name}'s #{poke_spawn.nickname || poke_ideal.name}"
      embed.description = "Level #{poke_spawn.level} #{poke_ideal.name}"
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

bot.command(:namerival) do |event, *words|
  if words.length.zero?
    I18n.t('name_rival.argument_error')
  else
    rival_name = words.join(' ')
    naming_result = Pokecord::Commands::NameRival.new(event.user.id.to_s, rival_name).call
    if naming_result.success?
      "#{event.user.mention} #{naming_result.value!}"
    else
      naming_result.failure
    end
  end
end

bot.command(:fight) do |event, fight_code|
  if fight_code.nil?
    I18n.t('fight.incorrect_code')
  else
    fight_result = Pokecord::Commands::Fight.new(event.user.id.to_s, fight_code).call
    if fight_result.success?
      "#{event.user.mention}, #{fight_result.value!}"
    else
      fight_result.failure
    end
  end
end

bot.command(:trade) do |event, subcommand, arg1|
  if subcommand.nil?
    I18n.t('trade.subcommand_error')
  else
    case subcommand
    when 'with'
      if arg1.nil?
        I18n.t('initiate_trade.argument_error')
      else
        result = Pokecord::Commands::InitiateTrade.new(event.user.id.to_s, arg1, event.user.name).call
        if result.success?
          "#{arg1}, you have been invited to trade with #{event.user.mention}. You can accept the invitation with `p!accept`."
        else
          result.failure
        end
      end
    when 'add'
      if arg1.nil?
        I18n.t('add_to_trade.argument_error')
      else
        result = Pokecord::Commands::ModifyTrade.new(event.user.id.to_s, arg1, action: :add).call
        if result.success?
          trade = result.value!
          old_message = event.channel.load_message(trade.message_discord_id)
          if old_message.nil?
            I18n.t('trade.discord_error')
          else
            old_message.edit('', Pokecord::EmbedTemplates::Trade.new(trade).to_embed)
          end
          nil
        else
          result.failure
        end
      end
    when 'remove'
      if arg1.nil?
        I18n.t('remove_from_trade.argument_error')
      else
        result = Pokecord::Commands::ModifyTrade.new(event.user.id.to_s, arg1, action: :remove).call
        if result.success?
          trade = result.value!
          old_message = event.channel.load_message(trade.message_discord_id)
          if old_message.nil?
            I18n.t('trade.discord_error')
          else
            old_message.edit('', Pokecord::EmbedTemplates::Trade.new(trade).to_embed)
          end
          nil
        else
          result.failure
        end
      end
    else
      I18n.t('trade.subcommand_error')
    end
  end
end

bot.command(:accept) do |event|
  result = Pokecord::Commands::AcceptTrade.new(event.user.id.to_s, event.user.name).call
  if result.success?
    trade = result.value!
    embed_message = event.channel.send_embed('', Pokecord::EmbedTemplates::Trade.new(trade).to_embed)
    Callbacks::UpdateTrade.new(trade).call(message_discord_id: embed_message.id)
    nil # don't send any message after the embed
  else
    result.failure
  end
end

bot.command(:confirm) do |event|
  confirm_result = Pokecord::Commands::ConfirmTrade.new(event.user.id.to_s).call
  if confirm_result.success?
    trade = confirm_result.value!
    if trade.user_1_confirm && trade.user_2_confirm
      execute_result = Pokecord::Commands::ExecuteTrade.new(trade.id).call
      if execute_result.success?
        trade_payload = execute_result.value!
        messages = []
        messages << "#{trade.user_1_name} and #{trade.user_2_name} have successfully exchanged Pokemon!"
        trade_payload.evolution_payloads.each do |evo_payload|
          familiar_name = evo_payload.spawned_pokemon.nickname || evo_payload.evolved_from.name
          messages << "What!? #{evo_payload.evolved_from.name} is evolving! Your #{familiar_name} has evolved into **#{evo_payload.evolved_into.name}**!!"
        end
        messages.join("\n")
      else
        execute_result.failure
      end
    end
  else
    confirm_result.failure
  end
end

bot.command(:balance) do |event|
  bal_result = Pokecord::Commands::Balance.new(event.user.id.to_s).call
  if bal_result.success?
    "You have **#{bal_result.value!}** credits."
  else
    bal_result.failure
  end
end

bot.command(:shop) do |event, page_num|
  if page_num.nil?
    embed = Pokecord::EmbedTemplates::ShopLandingPage.new.to_embed
    event.channel.send_embed('', embed)
    nil
  elsif page_num.to_i.between?(1, 4)
    embed = Pokecord::EmbedTemplates::ShopItemsPage.new(page_num.to_i).to_embed
    event.channel.send_embed('', embed)
    nil
  else
    I18n.t('shop.argument_error')
  end
end

bot.command(:buy) do |event, *args|
  if args.length.zero?
    I18n.t('buy.argument_error')
  else
    amount = args.last =~ /\A\d+\z/ ? args.pop.to_i : 1
    product_name = args.join(' ')
    buy_result = Pokecord::Commands::Buy.new(event.user.id.to_s, product_name, amount).call
    buy_result.success? ? "#{event.user.mention}, #{buy_result.value!}" : buy_result.failure
  end
end

bot.command(:inventory) do |event|
  result = Pokecord::Commands::ListInventory.new(event.user.id.to_s).call
  if result.success?
    inventory_items = result.value!
    embed = Pokecord::EmbedTemplates::InventoryList.new(event.user.name, inventory_items).to_embed
    event.channel.send_embed('', embed)
    nil
  else
    result.failure
  end
end

bot.command(:use) do |event, *args|
  if args.length.zero?
    I18n.t('use_item.argument_error')
  else
    product_name = args.join(' ')
    use_item_result = Pokecord::Commands::Use.new(event.user.id.to_s, product_name).call
    if use_item_result.success?
      evo_payload = use_item_result.value!
      familiar_name = evo_payload.spawned_pokemon.nickname || evo_payload.evolved_from.name
      "#{event.user.mention}! What!? #{evo_payload.evolved_from.name} is evolving! Your #{familiar_name} has evolved into **#{evo_payload.evolved_into.name}**!!"
    else
      use_item_result.failure
    end
  end
end

%w{
  order
  hint
  pokedex
  release
  mega
  moves
  learn
  replace
  duel
  bal
  market
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

# D&D commands

bot.command :role do |event|
  role_result = Dnd::Commands::AssignPartyRole.new(event.user.id.to_s).call
  if role_result.success?
    payload = role_result.value!
    event.user.pm(I18n.t('dnd.assign_party_role', primary: payload.primary.name, secondary: payload.secondary.name))
    "#{event.user.mention}, you have been sent a direct message with your randomized party role!"
  else
    role_result.failure
  end
end

#########################
#
### Admin commands
#
#########################

bot.command(:wild, permission_level: 2) do |event|
  wild_pokemon = Pokecord::WildPokemon.new
  wild_pokemon.spawn!
  event.send_file(File.open(wild_pokemon.pic_file, 'r'), caption: "A wild Pokemon appeared! You can try to catch it with `p!catch` (not implemented)")
end

bot.command(:admin, permission_level: 2) do |event, subcommand|
  case subcommand
  when 'reset_balances'
    result = Pokecord::Commands::Admin::ResetBalances.new.call
    result.success? ? result.value! : result.failure
  else
    I18n.t('admin.argument_error')
  end
end

bot.run
