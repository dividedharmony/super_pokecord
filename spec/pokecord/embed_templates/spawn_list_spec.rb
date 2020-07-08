# frozen_string_literal: true

require_relative '../../../lib/pokecord/embed_templates/spawn_list'

RSpec.describe Pokecord::EmbedTemplates::SpawnList do
  describe '#to_embed' do
    let(:username) { 'Spicy Douglas' }
    let(:pokemon1) { TestingFactory[:pokemon, name: 'George', pokedex_number: 433] }
    let(:pokemon2) { TestingFactory[:pokemon, name: 'Jennifer', pokedex_number: 9] }
    let(:pokemon3) { TestingFactory[:pokemon, name: 'Regina', pokedex_number: 987] }
    let(:spawned_pokemons) do
      [
        TestingFactory[
          :spawned_pokemon,
          pokemon_id: pokemon1.id,
          level: 4,
          catch_number: 18
        ],
        TestingFactory[
          :spawned_pokemon,
          pokemon_id: pokemon2.id,
          nickname: 'Flaafy',
          level: 13,
          catch_number: 45
        ],
        TestingFactory[
          :spawned_pokemon,
          pokemon_id: pokemon3.id,
          level: 67,
          catch_number: 1
        ]
      ]
    end
    let(:list_payload) do
      double(
        'List Payload',
        spawned_pokemons: spawned_pokemons,
        page_number: 3,
        total_pages: 22
      )
    end

    subject { described_class.new(username, list_payload).to_embed }

    it 'returns an embed with all of the appropriate information' do
      expect(subject.title).to eq("Spicy Douglas's Pokémon")
      expect(subject.color).to eq(3463403)
      expect(subject.description).to eq(
        "**George** --->  Level: 4, Pokedex number: 433, catch number: 18\n" +
        "**Jennifer** ---> nickname: Flaafy, Level: 13, Pokedex number: 9, catch number: 45\n" +
        "**Regina** --->  Level: 67, Pokedex number: 987, catch number: 1"
      )
      expect(subject.footer.text).to eq('Displaying page 3 of 22')
    end
  end
end
