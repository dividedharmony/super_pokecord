# frozen_string_literal: true

require_relative '../../lib/pokecord/fight_conditions'

RSpec.describe Pokecord::FightConditions do
  describe '#met?' do
    let(:gym_badges) { 0 }
    let(:elite_four_wins) { 0 }
    let(:champion_wins) { 0 }
    let(:user) do
      TestingFactory[
        :user,
        gym_badges: gym_badges,
        elite_four_wins: elite_four_wins,
        champion_wins: champion_wins
      ]
    end
    let(:fight_type) { TestingFactory[:fight_type] }
    let(:fight_conditions) { described_class.new(user, fight_type) }

    subject { fight_conditions.met? }

    context 'if fight_type.code is gym' do
      let(:fight_type) { TestingFactory[:fight_type, :gym] }

      context "if user's gym_badges divided by 8 are greater than the user's elite_four divided by 4" do
        let(:gym_badges) { 8 }
        let(:elite_four_wins) { 0 }

        it 'indicates conditions are not met' do
          is_expected.to be false
          expect(fight_conditions.error_message).to eq(
            'You must defeat the elite four before you can challenge any more gyms.'
          )
        end
      end

      context "if user's gym_badges divided by 8 is less than or equal to the user's elite_four divided by 4" do
        let(:gym_badges) { 24 }
        let(:elite_four_wins) { 12 }

        context "if user's gym_badges divided by 8 are greater than the user's champion_wins" do
          let(:champion_wins) { 2 }

          it 'indicates conditions are not met' do
            is_expected.to be false
            expect(fight_conditions.error_message).to eq(
              'You must defeat the Pokemon Champion before you can challenge any more gyms.'
            )
          end
        end

        context "if user's gym_badges divided by 8 is less than the user's champion_wins" do
          let(:champion_wins) { 3 }

          it { is_expected.to be true }
        end
      end
    end

    context 'if fight_type.code is elite_four' do
      let(:fight_type) { TestingFactory[:fight_type, :elite_four] }

      context "if user's gym_badges divided by 8 are less than or equal to the user's elite_four divided by 4" do
        let(:gym_badges) { 7 }
        let(:elite_four_wins) { 0 }

        it 'indicates conditions are not met' do
          is_expected.to be false
          expect(fight_conditions.error_message).to eq(
            "You must collect 8 badges before you can challenge the Elite Four."
          )
        end
      end

      context "if user's gym_badges divided by 8 are greater than the user's elite_four divided by 4" do
        let(:gym_badges) { 40 }
        let(:elite_four_wins) { 16 }

        context "if user's elite_four_wins divided by 4 is greater than the user's champion_wins" do
          let(:champion_wins) { 3 }

          it 'indicates conditions are not met' do
            is_expected.to be false
            expect(fight_conditions.error_message).to eq(
              "You have already beaten the Elite Four! Challenge the Pokemon Champion next!"
            )
          end
        end

        context "if user's elite_four_wins divided by 4 is less than or equal to the user's champion_wins" do
          let(:elite_four_wins) { 18 }
          let(:champion_wins) { 4 }

          it { is_expected.to be true }
        end
      end
    end

    context 'if fight_type.code is champion' do
      let(:fight_type) { TestingFactory[:fight_type, :champion] }

      context "if user's gym_badges divided by 8 is less than or equal to user's champion_wins" do
        let(:gym_cycles) { 23 }
        let(:champion_wins) { 3 }

        it 'indicates conditions are not met' do
          is_expected.to be false
          expect(fight_conditions.error_message).to eq(
            'You must collect 8 gym badges and defeat the Elite Four before you can challenge the Pokemon Champion.'
          )
        end
      end

      context "if user's gym_badges divided by 8 is greater than user's champion_wins" do
        let(:gym_cycles) { 32 }
        let(:champion_wins) { 3 }

        context "if user's elite_four_wins divided by 4 is less than or equal to the user's champion_wins" do
          let(:elite_four_wins) { 14 }

          it 'indicates conditions are not met' do
            is_expected.to be false
            expect(fight_conditions.error_message).to eq(
              'You must collect 8 gym badges and defeat the Elite Four before you can challenge the Pokemon Champion.'
            )
          end
        end

        context "if user's elite_four_wins divided by four is greater than the user's champion_wins" do
          let(:elite_four_wins) { 16 }

          it 'indicates conditions are not met' do
            is_expected.to be false
            expect(fight_conditions.error_message).to eq(
              'You must collect 8 gym badges and defeat the Elite Four before you can challenge the Pokemon Champion.'
            )
          end
        end
      end
    end

    context 'if fight_type.code is anything else' do
      it { is_expected.to be true }
    end
  end
end
