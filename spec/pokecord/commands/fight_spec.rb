# frozen_string_literal: true

require_relative '../../../lib/pokecord/commands/fight'

RSpec.describe Pokecord::Commands::Fight do
  describe '#call' do
    let(:discord_id) { '12345' }
    let(:fight_code) { 'gym' }
    let(:fight_command) { described_class.new(discord_id, fight_code) }

    subject { fight_command.call }

    around do |example|
      Timecop.freeze(Time.now) do
        example.run
      end
    end

    context 'if user with that discord_id does not exist' do
      it 'returns a Failure monad' do
        expect(subject).to be_failure
        result = subject.failure
        expect(result).to eq(I18n.t('user_needs_to_start'))
      end
    end

    context 'if current_pokemon is nil' do
      before do
        TestingFactory[:user, discord_id: '12345']
      end

      it 'returns a Failure monad' do
        expect(subject).to be_failure
        result = subject.failure
        expect(result).to eq(I18n.t('needs_a_current_pokemon'))
      end
    end

    context 'if fight code is invalid' do
      before do
        spawn = TestingFactory[:spawned_pokemon]
        TestingFactory[
          :user,
          discord_id: '12345',
          current_pokemon_id: spawn.id
        ]
      end

      it 'returns a Failure monad' do
        expect(subject).to be_failure
        result = subject.failure
        expect(result).to eq(I18n.t('fight.incorrect_code'))
      end
    end

    context 'if fight conditions are not met' do
      before do
        spawn = TestingFactory[:spawned_pokemon]
        TestingFactory[
          :user,
          :with_current_pokemon,
          discord_id: '12345',
          current_pokemon_id: spawn.id
        ]
        TestingFactory[:fight_type, :gym]
        mock_conditions = instance_double(Pokecord::FightConditions)
        expect(Pokecord::FightConditions).to receive(:new).with(any_args) { mock_conditions }
        expect(mock_conditions).to receive(:met?) { false }
        expect(mock_conditions).to receive(:error_message) { 'You stink' }
      end

      it 'returns a Failure monad' do
        expect(subject).to be_failure
        result = subject.failure
        expect(result).to eq('You stink')
      end
    end

    context 'if fight is not available yet' do
      before do
        spawn = TestingFactory[:spawned_pokemon]
        user = TestingFactory[
          :user,
          :with_current_pokemon,
          discord_id: '12345',
          current_pokemon_id: spawn.id
        ]
        fight_type = TestingFactory[:fight_type, :gym]
        TestingFactory[
          :fight_event,
          user: user,
          fight_type: fight_type,
          available_at: (Time.now + (3 * 60 * 60) + (48 * 60) + 2)
        ]
        mock_conditions = instance_double(Pokecord::FightConditions)
        expect(Pokecord::FightConditions).to receive(:new).with(any_args) { mock_conditions }
        expect(mock_conditions).to receive(:met?) { true }
      end

      it 'returns a Failure monad' do
        expect(subject).to be_failure
        result = subject.failure
        expect(result).to eq(
          I18n.t(
            'fight.not_available_yet',
            name: 'Trainer Bob',
            time: '3h 48m 2s'
          )
        )
      end
    end

    context 'if command is completely valid' do
      let(:fight_event_repo) do
        Repositories::FightEventRepo.new(
          Db::Connection.registered_container
        )
      end
      let(:user_repo) do
        Repositories::UserRepo.new(
          Db::Connection.registered_container
        )
      end
      let!(:spawn) { TestingFactory[:spawned_pokemon, level: 1] }
      let!(:user) do
        TestingFactory[
          :user,
          :with_current_pokemon,
          discord_id: '12345',
          current_pokemon_id: spawn.id,
          current_balance: 20
        ]
      end
      let!(:fight_type) do
        TestingFactory[
          :fight_type,
          :gym,
          time_delay: 60,
          max_reward: 11_001,
          min_reward: 11_000
        ]
      end

      before do
        mock_conditions = instance_double(Pokecord::FightConditions)
        expect(Pokecord::FightConditions).to receive(:new).with(any_args) { mock_conditions }
        expect(mock_conditions).to receive(:met?) { true }
      end

      context 'if user has never participated in this fight type before' do
        it 'creates a fight_event and returns a success' do
          expect { subject }.to change {
            fight_event_repo.fight_events.count
          }.from(0).to(1)
          fight_event = fight_event_repo.fight_events.first
          expect(fight_event.last_fought_at).to be_within(3).of(Time.now)
          expect(fight_event.available_at).to be_within(3).of(Time.now + 60)
          user_reload = user_repo.users.by_pk(user.id).one!
          expect(user_reload.current_balance).to eq(11_020)
          expect(subject.value!).to eq(
            I18n.t('fight.success', name: 'Trainer Bob', currency: 11_000)
          )
        end
      end

      context 'if user has participated in this fight type before' do
        let!(:fight_event) do
          TestingFactory[
            :fight_event,
            user: user,
            fight_type: fight_type,
            last_fought_at: (Time.now - (48 * 60 * 60)),
            available_at: (Time.now - (24 * 60 * 60))
          ]
        end

        it 'updates the existing fight_event and returns a success' do
          expect { subject }.not_to change {
            fight_event_repo.fight_events.count
          }.from(1)
          event_reload = fight_event_repo.fight_events.by_pk(fight_event.id).one!
          expect(event_reload.last_fought_at).to be_within(3).of(Time.now)
          expect(event_reload.available_at).to be_within(3).of(Time.now + 60)
          user_reload = user_repo.users.by_pk(user.id).one!
          expect(user_reload.current_balance).to eq(11_020)
          expect(subject.value!).to eq(
            I18n.t('fight.success', name: 'Trainer Bob', currency: 11_000)
          )
        end
      end
    end
  end
end
