# frozen_string_literal: true

require_relative '../../../lib/pokecord/embed_templates/offering_list'

RSpec.describe Pokecord::EmbedTemplates::OfferingList do
  describe '#to_s' do
    let(:user) { TestingFactory[:user] }
    let!(:trade) { TestingFactory[:trade] }
    let(:pokemon_1) { TestingFactory[:pokemon, name: 'Snorlax'] }
    let(:pokemon_2) { TestingFactory[:pokemon, name: 'Rolycoly'] }

    subject { described_class.new(user.id, trade.id).to_s }

    before do
      TestingFactory[
        :spawned_pokemon,
        user_id: user.id,
        trade_id: trade.id,
        pokemon_id: pokemon_1.id,
        level: 33,
        catch_number: 1
      ]
      TestingFactory[
        :spawned_pokemon,
        user_id: user.id,
        trade_id: trade.id,
        pokemon_id: pokemon_2.id,
        level: 12,
        catch_number: 2
      ]
      # spawn not owned by the user
      TestingFactory[
        :spawned_pokemon,
        trade_id: trade.id,
        pokemon_id: pokemon_2.id,
        level: 12,
        catch_number: 3
      ]
      # spawn not part of the trade
      TestingFactory[
        :spawned_pokemon,
        user_id: user.id,
        pokemon_id: pokemon_2.id,
        level: 12,
        catch_number: 4
      ]
    end

    it { is_expected.to eq("```Level 33 Snorlax (Catch number: 1)\nLevel 12 Rolycoly (Catch number: 2)```") }
  end
end
