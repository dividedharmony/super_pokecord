# main.rb

require 'dotenv/load'
require 'discordrb'


bot = Discordrb::Bot.new(token: ENV["DISCORD_TOKEN"])

poke_channels = (ENV["POKECORD_CHANNELS"] || "").split(',')
poke_steps = 0
poke_requirement = rand(35) + 10

bot.message(containing: not!("p!"), in: poke_channels) do |event|
  poke_steps += 1
  if poke_steps >= poke_requirement
    poke_steps = 0
    poke_requirement = rand(100) + 10
    random_pokedex_num = (rand(809) + 1).to_s.rjust(3, '0')
    pic_file = File.expand_path("pokemon_info/images/#{random_pokedex_num}.png", File.dirname(__FILE__))
    event.send_file(File.open(pic_file, 'r'), caption: 'A wild Pokemon appeared! You can try to catch it with `p!catch` (not implemented)')
  end
end

bot.run
