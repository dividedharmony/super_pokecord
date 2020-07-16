# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/info'

RSpec.describe Pokecord::Commands::Info do
  it_behaves_like 'a user command' do
    let(:command) { described_class.new('12345') }
  end

  it_behaves_like 'a command that requires a user to have a current_pokemon' do
    let(:command) { described_class.new('12345') }
  end

  describe '#call' do
    let!(:pokemon) { TestingFactory[:pokemon, name: 'Venom Ranger'] }
    let!(:spawn) { TestingFactory[:spawned_pokemon, pokemon_id: pokemon.id] }
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: '111111',
        current_pokemon_id: spawn.id
      ]
    end

    subject { described_class.new('111111').call }

    it 'returns a payload wrapped in a success monad' do
      expect(subject).to be_success
      payload = subject.value!
      expect(payload.spawned_pokemon.id).to eq(spawn.id)
      expect(payload.pokemon.name).to eq('Venom Ranger')
    end
  end
end
