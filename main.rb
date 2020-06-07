# main.rb

require 'dotenv/load'
require 'discordrb'

require_relative './lib/pokecord/wild_pokemon'

bot = Discordrb::Bot.new(token: ENV["DISCORD_TOKEN"])

poke_channels = (ENV["POKECORD_CHANNELS"] || "").split(',')
poke_steps = 0
poke_requirement = rand(11) + 5

bot.message(containing: not!("p!"), in: poke_channels) do |event|
  poke_steps += 1
  if poke_steps >= poke_requirement
    poke_steps = 0
    poke_requirement = rand(100) + 10
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
