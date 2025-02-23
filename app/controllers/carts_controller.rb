class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: cart_response, status: :ok
  end

  def add_product
    product = Product.find_by(id: params[:product_id])
    
    if product
      cart_item = @cart.cart_items.find_by(product: product)
      
      if cart_item
        cart_item.update(quantity: (cart_item.quantity || 0) + params[:quantity].to_i)
      else
        @cart.cart_items.create(product: product, quantity: params[:quantity])
      end
      
      @cart.touch
      @cart.update(abandoned_at: nil)
      
      render json: cart_response, status: :ok
    else
      render json: { error: 'Produto não encontrado' }, status: :not_found
    end
  end

  def remove_product
    product = find_product
    return render json: { error: "Produto não encontrado" }, status: :not_found if product.nil?
  
    cart_item = @cart.cart_items.find_by(product: product)
    return render json: { error: "Produto não encontrado no carrinho" }, status: :not_found if cart_item.nil?
  
    cart_item.destroy
    update_cart_timestamp
  
    render json: { message: "Produto removido do carrinho", cart: cart_response }, status: :ok
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create
    session[:cart_id] = @cart.id
  end

  def find_product
    Product.find_by(id: params[:product_id]) # ✅ Apenas retorna o produto ou nil
  end

  def update_cart_timestamp
    @cart.touch
    @cart.update(abandoned_at: nil)
  end

  def cart_response
    {
      id: @cart.id,
      products: @cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          total_price: (item.quantity * item.product.price).to_f
        }
      end,
      total_price: @cart.cart_items.sum { |item| item.quantity * item.product.price }.to_f
    }
  end
end
