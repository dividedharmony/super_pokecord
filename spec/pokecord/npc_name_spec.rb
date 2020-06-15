# frozen_string_literal: true

require_relative '../../lib/pokecord/npc_name'

RSpec.describe Pokecord::NpcName do
  describe '#to_s' do
    let(:npc_name) { described_class.new(fight_code) }

    subject { npc_name.to_s }

    context 'if the given fight_code is "rival"' do
      let(:fight_code) { 'rival' }

      context 'if user is nil' do
        it { is_expected.to eq('your rival ???') }
      end

      context 'if user is present' do
        let(:npc_name) { described_class.new(fight_code, user) }

        context 'if user has not named their rival' do
          let(:user) { TestingFactory[:user, rival_name: nil] }

          it { is_expected.to eq('your rival ???') }
        end

        context 'if user has named their rival' do
          let(:user) { TestingFactory[:user, rival_name: 'Blue'] }

          it { is_expected.to eq('your rival Blue') }
        end
      end
    end

    context 'if the given fight_code is "gym"' do
      let(:fight_code) { 'gym' }

      before do
        expect(Faker::Name).to receive(:first_name) { 'Jimmy' }
      end

      it { is_expected.to eq('Gym Leader Jimmy') }
    end

    context 'if the given fight_code is "elite_four"' do
      let(:fight_code) { 'elite_four' }

      before do
        expect(Faker::Name).to receive(:first_name) { 'Azula' }
      end

      it { is_expected.to eq('Elite Four Azula') }
    end

    context 'if the given fight_code is "champion"' do
      let(:fight_code) { 'champion' }

      before do
        expect(Faker::Name).to receive(:first_name) { 'Victoria' }
      end

      it { is_expected.to eq('Pokemon Champion Victoria') }
    end

    context 'if the given fight_code is anything else' do
      let(:fight_code) { 'rando' }

      before do
        expect(Faker::Name).to receive(:first_name) { 'Zuko' }
      end

      it { is_expected.to match /Zuko\z/ }
    end
  end
end
