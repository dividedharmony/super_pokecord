# main.rb

require 'dotenv/load'
require 'discordrb'
require 'i18n'

require_relative './lib/pokecord/spawn_rate'
require_relative './lib/pokecord/wild_pokemon'
require_relative './lib/pokecord/step_counter'

I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
I18n.default_locale = :en

bot = Discordrb::Bot.new(token: ENV["DISCORD_TOKEN"])

poke_channels = (ENV["POKECORD_CHANNELS"] || "").split(',')
spawn_rate = Pokecord::SpawnRate.new(5, 15)
previous_discord_id = nil

bot.message(containing: not!("p!"), in: poke_channels) do |event|
  # Step exp logic
  current_discord_id = event.user.id.to_s
  level_up_payload = Pokecord::StepCounter.new(current_discord_id).step!(previous_discord_id)
  previous_discord_id = current_discord_id
  if level_up_payload
    current_poke_spawn = level_up_payload.spawned_pokemon
    poke_name = current_poke_spawn.nickname || current_poke_spawn.pokemon.name
    event.respond("Congrats, #{event.user.mention}! Your **#{poke_name}** has leveled up to #{level_up_payload.level}!")
    if level_up_payload.evolved_into
      event.respond("What's this? Your #{poke_name} has evolved into a **#{level_up_payload.evolved_into.name}**!!")
    end
  end
  # Spawn Logic
  spawn_rate.step!
  if spawn_rate.should_spawn?
    spawn_rate.reset!
    # spawn a wild pokemon
    wild_pokemon = Pokecord::WildPokemon.new
    wild_pokemon.spawn!
    event.send_file(
      File.open(wild_pokemon.pic_file, 'r'),
      caption: "A wild Pokemon appeared! You can try to catch it with `p!catch` (not implemented)"
    )
  end
end

bot.run
