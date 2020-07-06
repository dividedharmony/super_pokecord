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
            name: 'gym',
            time: '3h 48m 1s'
          )
        )
      end
    end

    context 'if command is otherwise valid' do
      let(:fight_event_repo) do
        Repositories::FightEventRepo.new(
          Db::Connection.registered_container
        )
      end
      let!(:user) do
        TestingFactory[
          :user,
          :with_current_pokemon,
          discord_id: '12345',
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
        mock_npc_name = instance_double(Pokecord::NpcName)
        expect(Pokecord::NpcName).to receive(:new).with('gym', duck_type(:rival_name)) { mock_npc_name }
        expect(mock_npc_name).to receive(:to_s) { 'Lady Amanda' }
      end

      context 'if user has never participated in this fight type before' do
        before do
          mock_updater = instance_double(Pokecord::FightUpdater)
          expect(Pokecord::FightUpdater).
            to receive(:new).with(user, anything, fight_type) { mock_updater }
          expect(mock_updater).to receive(:call) { Dry::Monads::Result::Success.new(1_234) }
        end

        it 'creates a new fight_event' do
          expect { subject }.to change {
            fight_event_repo.fight_events.count
          }.from(0).to(1)
          expect(subject.value!).to eq(
            I18n.t('fight.success', name: 'Lady Amanda', currency: ReadableNumber.stringify(1_234))
          )
        end
      end

      context 'if user has participated in this fight event before' do
        let!(:fight_event) do
          TestingFactory[
            :fight_event,
            user: user,
            fight_type: fight_type,
            available_at: Time.now - (5 * 60)
          ]
        end

        before do
          mock_updater = instance_double(Pokecord::FightUpdater)
          expect(Pokecord::FightUpdater).
            to receive(:new).with(
              having_attributes(id: user.id),
              having_attributes(id: fight_event.id),
              having_attributes(id: fight_type.id)
            ) { mock_updater }
          expect(mock_updater).to receive(:call) { Dry::Monads::Result::Success.new(1_234) }
        end

        it 'does not create a new fight event' do
          expect { subject }.not_to change {
            fight_event_repo.fight_events.count
          }.from(1)
          expect(subject.value!).to eq(
            I18n.t('fight.success', name: 'Lady Amanda', currency: ReadableNumber.stringify(1_234))
          )
        end
      end
    end
  end
end
