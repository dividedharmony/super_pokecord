# frozen_string_literal: true

require 'faker'

module Pokecord
  class NpcName
    # based on https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_Trainer#Trainer_class
    TRAINER_TITLES = [
      'Beauty',
      'Biker',
      'Bird Keeper',
      'Blackbelt',
      'Boss',
      'Bug Catcher',
      'Burglar',
      'Channeler',
      'Cooltrainer',
      'Cue Ball',
      'Engineer',
      'Fisher',
      'Gambler',
      'Gentleman',
      'Juggler',
      'Jr. Trainer',
      'Lass',
      'PokeManiac',
      'Psychic',
      'Sailor',
      'Scientist',
      'Super Nerd',
      'Swimmer',
      'Tamer',
      'Youngster',
      'Camper',
      'Firebreather',
      'Guitarist',
      'Kimono Girl',
      'Medium',
      'Officer',
      'Picnicker',
      'Pokefan',
      'Sage',
      'Schoolboy',
      'Schoolgirl',
      'Skier',
      'Teacher',
      'Bug Maniac',
      'Aroma Lady',
      'Collector',
      'Dragon Tamer',
      'Expert',
      'Hex Maniac',
      'Interviewer',
      'Ninja Boy',
      'Ninja Girl',
      'Parasol Lady',
      'Parasol Boi',
      'Pokemon Breeder',
      'Pokemon Ranger',
      'Rich Boi',
      'Rich Gurl',
      'Triathlete',
      'Tuber',
      'Painter',
      'Arena Tycoon',
      'Factory Head',
      'Salon Maiden',
      'Pyramid King',
      'Pyramid Queen',
      'Bodybuilder',
      'Fun Old Man',
      'Fun Old Lady',
      'Cipher Peon',
      'Glasses Man',
      'Glasses Woman',
      'Hunter',
      'Myth Trainer',
      'Shady Guy',
      'Shady Lady',
      'Supertrainer',
      'Worker',
      'Casual Dude',
      'Casual Dudette',
      'Navigator',
      'Thug',
      'Spy',
      'Wanderer',
      'Artist',
      'Cameraperson',
      'Clown',
      'Commander',
      'Cowgirl',
      'Cyclist',
      'Idol',
      'Jogger',
      'Poke kid',
      'Rancher',
      'Socialite',
      'Veteran',
      'Waiter',
      'Bug-Catching Man',
      'Bug-Catching Woman',
      'Challenger',
      'Crush Kin',
      'Electrifying Guy',
      'Electrifying Girl',
      'Hiking Club Member',
      'Future Girl',
      'Girl in Love',
      'Boy with Love',
      'High-Tech Maniac',
      'Hardheaded Girl',
      'Leader-in-Training',
      'Little Queen',
      'Lone Wolf',
      'Muddy Boi',
      'Muddy Gurl',
      'New Star',
      'Ordinary Person',
      'Passionate Person',
      'Pikachu Fan',
      'Poison Tongue Boy',
      'Poison Tongue Girl',
      'Sci-Fi Maniac',
      'Sightseer',
      'Steel Spirit',
      'Stubborn Boy',
      'Stubborn Girl',
      'Tomboy',
      'Maid',
      'Butler',
      'Arcade Star',
      'Hall Matron',
      'Elder',
      'Actor',
      'Actress',
      'A-list Actor',
      'Celebrity',
      'Child Star',
      'Comedian',
      'Fine Actor',
      'Veteran Star',
      'Baker',
      'Clerk',
      'Dancer',
      'Doctor',
      'GAME FREAK',
      'Harlequin',
      'Hooligan',
      'Janitor',
      'Linebacker',
      'Motorcyclist',
      'Musician',
      'Nurse',
      'Pilot',
      'Preschooler',
      'Smasher',
      'Striker',
      'Subway Boss',
      'Baron',
      'Baroness',
      'Chef',
      'Count',
      'Countess',
      'Driver',
      'Duke',
      'Duchess',
      'Earl',
      'Fairy Tale Girl',
      'Fairy Tale Boy',
      'Gardener',
      'Honeymooner',
      'Marchioness',
      'Marquis',
      'Monsieur',
      'Prof.',
      'Punk Girl',
      'Punk Guy',
      'Roller Skater',
      'Sky Trainer',
      'Successor',
      'Suspicious Child',
      'Viscount',
      'Viscountess',
      'Delinquent',
      'Lorekeeper',
      'Scuba Diver',
      'Sootopolitan',
      'Street Thug',
      'Captain',
      'Cook',
      'Bellhop',
      'Island Kahuna',
      'Karate Master',
      'Masked Man',
      'Masked Woman',
      'Cabbie',
      'Café Master',
      'Model'
    ].freeze

    def initialize(fight_code)
      @fight_code = fight_code
      @name = Faker::Name.first_name
    end

    def to_s
      case fight_code
      when 'rival' then 'your rival ???'
      when 'gym' then "Gym Leader #{name}"
      when 'elite_four' then "Elite Four #{name}"
      when 'champion' then "Pokemon Champion #{name}"
      else
        "#{TRAINER_TITLES.sample} #{name}"
      end
    end

    private

    attr_reader :fight_code, :name
  end
end
