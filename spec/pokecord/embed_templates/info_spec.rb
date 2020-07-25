# frozen_string_literal: true

require_relative '../../../lib/entities/pokemon'
require_relative '../../../lib/pokecord/embed_templates/info'

RSpec.describe Pokecord::EmbedTemplates::Info do
  describe '#to_embed' do
    let(:pokemon) do
      TestingFactory[
        :pokemon,
        name: 'VideoMan',
        pokedex_number: 87,
        base_hp: 500,
        base_attack: 12,
        base_defense: 15,
        base_sp_attack: 20,
        base_sp_defense: 17,
        base_speed: 333
      ]
    end
    let(:caught_at) { Time.now - (24 * 60 * 60) }
    let(:spawned_pokemon) do
      TestingFactory[
        :spawned_pokemon,
        nickname: nickname,
        level: 34,
        caught_at: caught_at
      ]
    end
    let(:info_payload) do
      double(
        'InfoPayload',
        spawned_pokemon: spawned_pokemon,
        pokemon: pokemon
      )
    end
    let(:embed_template) { described_class.new('Cap. Jack', info_payload) }

    subject { embed_template.to_embed }

    context 'if spawn has a nickname' do
      let(:nickname) { 'Franchise' }

      it 'displays info on the pokemon and its spawn' do
        expect(subject.title).to eq("Cap. Jack's Franchise")
        expect(subject.description).to eq('Level 34 VideoMan')
        expect(subject.color).to eq(3463403)
        expect(subject.fields[0].name).to eq('Pokedex No.')
        expect(subject.fields[0].value).to eq('087')
        expect(subject.fields[0].inline).to be true
        expect(subject.fields[1].name).to eq('HP')
        expect(subject.fields[1].value).to eq(500)
        expect(subject.fields[1].inline).to be true
        expect(subject.fields[2].name).to eq('Attack')
        expect(subject.fields[2].value).to eq(12)
        expect(subject.fields[2].inline).to be true
        expect(subject.fields[3].name).to eq('Defense')
        expect(subject.fields[3].value).to eq(15)
        expect(subject.fields[3].inline).to be true
        expect(subject.fields[4].name).to eq('Sp. Attack')
        expect(subject.fields[4].value).to eq(20)
        expect(subject.fields[4].inline).to be true
        expect(subject.fields[5].name).to eq('Sp. Defense')
        expect(subject.fields[5].value).to eq(17)
        expect(subject.fields[5].inline).to be true
        expect(subject.fields[6].name).to eq('Speed')
        expect(subject.fields[6].value).to eq(333)
        expect(subject.fields[6].inline).to be true
        expect(subject.fields[7].name).to eq('Caught At')
        expect(subject.fields[7].value).to eq(caught_at.strftime('%Y-%m-%d'))
        expect(subject.fields[7].inline).to be true
      end
    end

    context 'if spawn does not have a nickname' do
      let(:nickname) { nil }

      it 'displays info on the pokemon and its spawn' do
        expect(subject.title).to eq("Cap. Jack's VideoMan")
        expect(subject.description).to eq('Level 34 VideoMan')
        expect(subject.color).to eq(3463403)
        expect(subject.fields[0].name).to eq('Pokedex No.')
        expect(subject.fields[0].value).to eq('087')
        expect(subject.fields[0].inline).to be true
        expect(subject.fields[1].name).to eq('HP')
        expect(subject.fields[1].value).to eq(500)
        expect(subject.fields[1].inline).to be true
        expect(subject.fields[2].name).to eq('Attack')
        expect(subject.fields[2].value).to eq(12)
        expect(subject.fields[2].inline).to be true
        expect(subject.fields[3].name).to eq('Defense')
        expect(subject.fields[3].value).to eq(15)
        expect(subject.fields[3].inline).to be true
        expect(subject.fields[4].name).to eq('Sp. Attack')
        expect(subject.fields[4].value).to eq(20)
        expect(subject.fields[4].inline).to be true
        expect(subject.fields[5].name).to eq('Sp. Defense')
        expect(subject.fields[5].value).to eq(17)
        expect(subject.fields[5].inline).to be true
        expect(subject.fields[6].name).to eq('Speed')
        expect(subject.fields[6].value).to eq(333)
        expect(subject.fields[6].inline).to be true
        expect(subject.fields[7].name).to eq('Caught At')
        expect(subject.fields[7].value).to eq(caught_at.strftime('%Y-%m-%d'))
        expect(subject.fields[7].inline).to be true
      end
    end
  end
end
