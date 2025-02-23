require 'rails_helper'

RSpec.describe ManageAbandonedCartsJob, type: :job do
  describe '#perform' do
    it 'marks carts as abandoned after 3 hours of inactivity' do
      # Cria um carrinho abandonado há mais de 3 horas usando a factory
      cart = create(:cart, updated_at: 4.hours.ago)

      # Executa o Job
      ManageAbandonedCartsJob.perform_now

      # Verifica se o carrinho foi marcado como abandonado
      expect(cart.reload.abandoned_at).not_to be_nil
    end

    it 'removes carts abandoned for more than 7 days' do
      # Cria um carrinho abandonado há mais de 7 dias usando a factory
      cart = create(:cart, abandoned_at: 8.days.ago)

      # Executa o Job
      ManageAbandonedCartsJob.perform_now

      # Verifica se o carrinho foi removido
      expect(Cart.exists?(cart.id)).to be_falsey
    end
  end
end