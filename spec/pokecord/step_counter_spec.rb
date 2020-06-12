# frozen_string_literal: true

require_relative '../../lib/pokecord/step_counter'

RSpec.describe Pokecord::StepCounter do
  describe '#step!' do
    let(:spawn_repo) do
      Repositories::SpawnedPokemonRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:user_repo) do
      Repositories::UserRepo.new(
        Db::Connection.registered_container
      )
    end
    let(:previous_discord_id) { '987654321' }
    let(:step_counter) { described_class.new('123456789') }

    subject { step_counter.step!(previous_discord_id) }

    context 'if user with that discord_id does not exit' do
      it 'does nothing' do
        is_expected.to be_nil
      end
    end

    context 'if user with that discord_id does exist' do
      before do
        @user = TestingFactory[:user, discord_id: '123456789']
      end

      context 'user does not have a current_pokemon' do
        it 'does nothing' do
          is_expected.to be_nil
        end
      end

      context 'user does have a current_pokemon' do
        let(:leveled_up) { false }
        let(:current_level) { 13 }

        before do
          @spawn_pokemon = TestingFactory[
            :spawned_pokemon,
            :caught,
            user: @user
          ]
          update_cmd = user_repo.users.by_pk(@user.id).command(:update)
          update_cmd.call(current_pokemon_id: @spawn_pokemon.id)
          @user = user_repo.users.where(id: @user.id).one!
          # mock ExpApplier
          mock_exp_applier = instance_double(
            Pokecord::ExpApplier,
            apply!: nil,
            leveled_up: leveled_up,
            current_level: current_level
          )
          expect(Pokecord::ExpApplier).to receive(:new).with(any_args) { mock_exp_applier }
        end

        context "if user's discord_id matches the previous user's discord_id" do
          let(:previous_discord_id) { '123456789' }

          context "if user's exp_per_step is already at or below 25 exp/step" do
            before do
              update_cmd = user_repo.users.by_pk(@user.id).command(:update)
              update_cmd.call(exp_per_step: 25)
              @user = user_repo.users.where(id: @user.id).one!
            end

            context 'if the current_pokemon levels up' do
              let(:leveled_up) { true }

              it 'returns the new level' do
                expect { subject }.not_to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(25)
                expect(subject).to eq(13)
              end
            end

            context 'if the current_pokemon does not level up' do
              let(:leveled_up) { false }

              it 'returns nil' do
                expect { subject }.not_to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(25)
                expect(subject).to be_nil
              end
            end
          end

          context "if user's exp_per_step is above 25 exp/step" do
            before do
              update_cmd = user_repo.users.by_pk(@user.id).command(:update)
              update_cmd.call(exp_per_step: 36)
              @user = user_repo.users.where(id: @user.id).one!
            end

            context 'if the current_pokemon levels up' do
              let(:leveled_up) { true }

              it 'lowers the user.exp_per_step and returns the new level' do
                expect { subject }.to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(36).to(35)
                expect(subject).to eq(13)
              end
            end

            context 'if the current_pokemon does not level up' do
              let(:leveled_up) { false }

              it 'lowers the user.exp_per_step and returns nil' do
                expect { subject }.to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(36).to(35)
                expect(subject).to be_nil
              end
            end
          end
        end

        context "if user's discord_id does not match the previous discord_id" do
          let(:previous_discord_id) { '111111111' }

          context "if user's exp_per_step is already at or above 50 exp/step" do
            before do
              update_cmd = user_repo.users.by_pk(@user.id).command(:update)
              update_cmd.call(exp_per_step: 50)
              @user = user_repo.users.where(id: @user.id).one!
            end

            context 'if the current_pokemon levels up' do
              let(:leveled_up) { true }

              it 'returns the new level' do
                expect { subject }.not_to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(50)
                expect(subject).to eq(13)
              end
            end

            context 'if the current_pokemon does not level up' do
              let(:leveled_up) { false }

              it 'returns nil' do
                expect { subject }.not_to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(50)
                expect(subject).to be_nil
              end
            end
          end

          context "if user's exp_per_step is below 50 exp/step" do
            before do
              update_cmd = user_repo.users.by_pk(@user.id).command(:update)
              update_cmd.call(exp_per_step: 42)
              @user = user_repo.users.where(id: @user.id).one!
            end

            context 'if the current_pokemon levels up' do
              let(:leveled_up) { true }

              it 'returns the new level' do
                expect { subject }.to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(42).to(43)
                expect(subject).to eq(13)
              end
            end

            context 'if the current_pokemon does not level up' do
              let(:leveled_up) { false }

              it 'returns nil' do
                expect { subject }.to change {
                  user_repo.users.where(id: @user.id).one.exp_per_step
                }.from(42).to(43)
                expect(subject).to be_nil
              end
            end
          end
        end
      end
    end
  end
end
