# frozen_string_literal: true

RSpec.shared_examples 'a user command' do
  # let(:command) { instance of command being tested }

  context 'if user with given discord_id does not exist' do
    it 'requires user to have started to use this command' do
      result = command.call
      expect(result).to be_failure
      expect(result.failure).to eq(I18n.t('user_needs_to_start'))
    end
  end

  context 'if user with given discord_id does exist' do
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: command.send(:discord_id)
      ]
    end

    it 'does not require user to have been started' do
      result = command.call
      if result.success?
        expect(result).to be_success
      else
        expect(result.failure).not_to eq(I18n.t('user_needs_to_start'))
      end
    end
  end
end

RSpec.shared_examples 'an inventory command' do
  # let(:command) { instance of command being tested }

  it_behaves_like 'a user command'

  describe 'existence of a product' do
    let!(:user) do
      TestingFactory[
        :user,
        discord_id: command.send(:discord_id)
      ]
    end

    context 'if product does not exist' do
      it 'returns a failure monad' do
        result = command.call
        expect(result).to be_failure
        expect(result.failure).to eq(
          I18n.t('inventory.no_such_product', product_name: command.send(:product_name))
        )
      end
    end

    context 'if product does exist' do
      let!(:product) do
        TestingFactory[
          :product,
          name: command.send(:product_name),
          visible: visible,
          price: 500
        ]
      end

      context 'if product is not visible' do
        let(:visible) { false }

        it 'returns a failure monad' do
          result = command.call
          expect(result).to be_failure
          expect(result.failure).to eq(
            I18n.t('inventory.no_such_product', product_name: product.name)
          )
        end
      end

      context 'if product is visible' do
        let(:visible) { true }

        it 'does not fail the command because the product does not exist' do
          result = command.call
          if result.success?
            expect(result).to be_success
          else
            expect(result.failure).not_to eq(
              I18n.t(
                'inventory.no_such_product',
                product_name: command.send(:product_name)
              )
            )
          end
        end
      end
    end
  end
end
