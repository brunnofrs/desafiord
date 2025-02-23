require 'rails_helper'

RSpec.describe "/cart", type: :request do
  let!(:product) { Product.create(name: "Test Product", price: 10.0) }

  describe "POST /cart/add_product" do
    before { post '/cart/add_product', params: { product_id: product.id, quantity: 1 }, as: :json }

    it "adiciona o produto ao carrinho" do
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["products"].first["id"]).to eq(product.id)
      expect(json_response["products"].first["quantity"]).to eq(1)
    end

    it "incrementa a quantidade de um produto já existente no carrinho" do
      expect {
        post '/cart/add_product', params: { product_id: product.id, quantity: 2 }, as: :json
      }.to change { CartItem.find_by(product: product).quantity }.by(2)
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:cart) { Cart.create }
    let!(:cart_item) { cart.cart_items.create(product: product, quantity: 2) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
    end

    it "remove o produto do carrinho" do
      delete "/cart/#{product.id}"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["cart"]["products"]).to be_empty
    end

    it "retorna erro ao tentar remover um produto inexistente" do
      delete "/cart/999"
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Produto não encontrado")
    end
  end
end
