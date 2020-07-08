# frozen_string_literal: true

require_relative '../../lib/repositories/spawned_pokemon_repo'

RSpec.describe Repositories::SpawnedPokemonRepo do
  let(:spawn_repo) { described_class.new(Db::Connection.registered_container) }

  describe '#by_user' do
    let!(:user) { TestingFactory[:user] }
    let!(:spawn) { TestingFactory[:spawned_pokemon, user_id: caught_by_id] }

    subject { spawn_repo.by_user(user) }

    context 'if spawn was caught by the given user' do
      let(:caught_by_id) { user.id }

      it 'includes the spawn' do
        expect(subject.to_a.map(&:id)).to include(spawn.id)
      end
    end

    context 'if spawn was not caught by the given user' do
      let(:caught_by_id) { TestingFactory[:user].id }

      it 'includes the spawn' do
        expect(subject.to_a.map(&:id)).not_to include(spawn.id)
      end
    end
  end

  describe '#favorited_by' do
    let!(:user) { TestingFactory[:user] }
    let(:favorite) { true }
    let!(:spawn) do
      TestingFactory[
        :spawned_pokemon,
        user_id: caught_by_id,
        favorite: favorite
      ]
    end

    subject { spawn_repo.favorited_by(user) }

    context 'if spawn was caught by the given user' do
      let(:caught_by_id) { user.id }

      context 'if user did not favorite the spawn' do
        let(:favorite) { false }

        it 'does not include the spawn' do
          expect(subject.to_a.map(&:id)).not_to include(spawn.id)
        end
      end

      context 'if user did favorite the spawn' do
        let(:favorite) { true }

        it 'includes the spawn' do
          expect(subject.to_a.map(&:id)).to include(spawn.id)
        end
      end
    end

    context 'if spawn was not caught by the given user' do
      let(:caught_by_id) { TestingFactory[:user].id }

      it 'does not include the spawn' do
        expect(subject.to_a.map(&:id)).not_to include(spawn.id)
      end
    end
  end
end
