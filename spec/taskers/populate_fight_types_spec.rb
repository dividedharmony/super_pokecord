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
end
