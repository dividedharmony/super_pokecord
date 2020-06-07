# main.rb

require 'dotenv/load'
require 'discordrb'

require_relative './lib/pokecord/spawn_rate'
require_relative './lib/pokecord/wild_pokemon'

bot = Discordrb::Bot.new(token: ENV["DISCORD_TOKEN"])

poke_channels = (ENV["POKECORD_CHANNELS"] || "").split(',')
spawn_rate = Pokecord::SpawnRate.new(5, 15)

bot.message(containing: not!("p!"), in: poke_channels) do |event|
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
