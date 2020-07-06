# frozen_string_literal: true

require_relative '../../lib/pokecord/fight_updater'

RSpec.describe Pokecord::FightUpdater do
  describe '#call' do
    let(:user_repo) do
      Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:fight_event_repo) do
      Repositories::FightEventRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:spawned_pokemon) { TestingFactory[:spawned_pokemon, level: 1] }
    let(:user) do
      user_without_pokemon = TestingFactory[
        :user,
        current_pokemon_id: spawned_pokemon.id,
        current_balance: 14,
        gym_badges: 13,
        elite_four_wins: 205,
        champion_wins: 4
      ]
      user_repo.users.combine(:current_pokemon).by_pk(user_without_pokemon.id).one
    end
    let(:fight_type) do
      TestingFactory[
        :fight_type,
        code: code,
        max_reward: 10_001,
        min_reward: 10_000,
        pokemon_multiplier_reward: 1,
        time_delay: (12 * 60 * 60)
      ]
    end
    let(:fight_event) do
      TestingFactory[
        :fight_event,
        user: user,
        fight_type: fight_type,
        last_fought_at: Time.now - (25 * 60 * 60),
        available_at: Time.now - (60 * 60)
      ]
    end
    let(:fight_updater) { described_class.new(user, fight_event, fight_type) }

    subject { fight_updater.call }

    context 'if fight_type is gym' do
      let(:code) { 'gym' }

      it "user's current_balance and gym_badges are updated" do
        expect { subject }.to change {
          user_repo.users.by_pk(user.id).one.current_balance
        }.from(14).to(10_014)
        expect(subject.value!).to eq(10_000)
        reloaded_user = user_repo.users.by_pk(user.id).one
        expect(reloaded_user.gym_badges).to eq(14)
        expect(reloaded_user.elite_four_wins).to eq(205)
        expect(reloaded_user.champion_wins).to eq(4)
        reloaded_event = fight_event_repo.fight_events.by_pk(fight_event.id).one
        expect(reloaded_event.last_fought_at).to be_within(5).of(Time.now)
        expect(reloaded_event.available_at).to be_within(5).of(Time.now + (12 * 60 * 60))
      end
    end

    context 'if fight_type is elite_four' do
      let(:code) { 'elite_four' }

      it "user's current_balance and elite_four_wins are updated" do
        expect { subject }.to change {
          user_repo.users.by_pk(user.id).one.current_balance
        }.from(14).to(10_014)
        expect(subject.value!).to eq(10_000)
        reloaded_user = user_repo.users.by_pk(user.id).one
        expect(reloaded_user.gym_badges).to eq(13)
        expect(reloaded_user.elite_four_wins).to eq(206)
        expect(reloaded_user.champion_wins).to eq(4)
        reloaded_event = fight_event_repo.fight_events.by_pk(fight_event.id).one
        expect(reloaded_event.last_fought_at).to be_within(5).of(Time.now)
        expect(reloaded_event.available_at).to be_within(5).of(Time.now + (12 * 60 * 60))
      end
    end

    context 'if fight_type is champion' do
      let(:code) { 'champion' }

      it "user's current_balance and champion_wins are updated" do
        expect { subject }.to change {
          user_repo.users.by_pk(user.id).one.current_balance
        }.from(14).to(10_014)
        expect(subject.value!).to eq(10_000)
        reloaded_user = user_repo.users.by_pk(user.id).one
        expect(reloaded_user.gym_badges).to eq(13)
        expect(reloaded_user.elite_four_wins).to eq(205)
        expect(reloaded_user.champion_wins).to eq(5)
        reloaded_event = fight_event_repo.fight_events.by_pk(fight_event.id).one
        expect(reloaded_event.last_fought_at).to be_within(5).of(Time.now)
        expect(reloaded_event.available_at).to be_within(5).of(Time.now + (12 * 60 * 60))
      end
    end

    context 'if fight_type is anything else' do
      let(:code) { 'rival' }

      it "only the user's current_balance is updated" do
        expect { subject }.to change {
          user_repo.users.by_pk(user.id).one.current_balance
        }.from(14).to(10_014)
        expect(subject.value!).to eq(10_000)
        reloaded_user = user_repo.users.by_pk(user.id).one
        expect(reloaded_user.gym_badges).to eq(13)
        expect(reloaded_user.elite_four_wins).to eq(205)
        expect(reloaded_user.champion_wins).to eq(4)
        reloaded_event = fight_event_repo.fight_events.by_pk(fight_event.id).one
        expect(reloaded_event.last_fought_at).to be_within(5).of(Time.now)
        expect(reloaded_event.available_at).to be_within(5).of(Time.now + (12 * 60 * 60))
      end
    end
  end
end
