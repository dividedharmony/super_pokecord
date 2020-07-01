# frozen_string_literal: true

require_relative '../../lib/taskers/populate_fight_types'

RSpec.describe Taskers::PopulateFightTypes do
  describe '#call' do
    let(:fight_type_repo) do
      Repositories::FightTypeRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:mock_output) { double('STDOUT') }

    subject { described_class.new(mock_output).call }

    before do
      allow(mock_output).to receive(:puts).with(instance_of(String))
    end

    context 'if none of the specified fight_types exist' do
      it 'populates the fight_types' do
        expect { subject }.to change {
          fight_type_repo.fight_types.count
        }.from(0).to(5)
        rando_type = fight_type_repo.fight_types.where(code: 'rando').one!
        expect(rando_type.time_delay).to eq(Duration.minutes_in_seconds(15))

        rival_type = fight_type_repo.fight_types.where(code: 'rival').one!
        expect(rival_type.time_delay).to eq(Duration.hours_in_seconds(1))

        gym_type = fight_type_repo.fight_types.where(code: 'gym').one!
        expect(gym_type.time_delay).to eq(Duration.hours_in_seconds(24))

        elite_four_type = fight_type_repo.fight_types.where(code: 'elite_four').one!
        expect(elite_four_type.time_delay).to eq(Duration.hours_in_seconds(24))

        champion_type = fight_type_repo.fight_types.where(code: 'champion').one!
        expect(champion_type.time_delay).to eq(Duration.hours_in_seconds(24))
      end
    end

    context 'if one (or more) of the specified fight_types exist' do
      let!(:rival_type) do
        TestingFactory[
          :fight_type,
          code: 'rival',
          time_delay: Duration.hours_in_seconds(15),
          max_reward: 10,
          min_reward: 5,
          pokemon_multiplier_reward: 1,
          created_at: Time.now - (5 * 24 * 60 * 60)
        ]
      end

      it 'updates the existing fight_type' do
        expect { subject }.to change {
          fight_type_repo.fight_types.count
        }.from(1).to(5)

        rival_reloaded = fight_type_repo.fight_types.by_pk(rival_type.id).one!
        expect(rival_reloaded.time_delay).to eq(Duration.hours_in_seconds(1))
        expect(rival_reloaded.max_reward).to eq(3500)
        expect(rival_reloaded.min_reward).to eq(2500)
        expect(rival_reloaded.pokemon_multiplier_reward).to eq(5)
        expect(rival_reloaded.created_at).to be_within(5).of(Time.now - (5 * 24 * 60 * 60))
      end
    end
  end
end
