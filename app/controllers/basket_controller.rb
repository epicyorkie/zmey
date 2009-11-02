class BasketController < ApplicationController
  before_filter :find_basket
  
  before_filter :require_delivery_address, :only => 'place_order'

  def index
    @page = params[:page_id] ? Page.find_by_id(params[:page_id]) : nil
  end

  def add
    product = Product.find_by_id_and_website_id(params[:product_id], @w.id)
    if product.nil?
      flash[:notice] = "Oops, we can't add that product to the basket."
      redirect_to request.referrer and return
    end
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    feature_selections = get_feature_selections
    unless flash[:notice].nil?
      redirect_to request.referrer and return
    end
    feature_descriptions = BasketItem.describe_feature_selections(feature_selections)

    # Look for an item that is in our basket, has the same product ID
    # and also has the same feature selections by the user.
    # For example, a T-shirt product with a single SKU may come in green or red,
    # each of which should appear as a separate entry in our basket.
    item = BasketItem.find_by_basket_id_and_product_id_and_feature_descriptions(@basket.id, product.id, feature_descriptions)
    if item
      item.quantity += quantity
    else
      item = BasketItem.new(
        :basket_id => @basket.id,
        :product_id => product.id,
        :quantity => quantity,
        :feature_selections => feature_selections)
    end
    item.save
    flash[:notice] = 'Added to basket'
    if params[:page_id].nil?
      redirect_to :action => 'index'
    else
      redirect_to :action => 'index', :page_id => params[:page_id]
    end
  end
  
  def update
    update_quantities if params[:update_quantities]
    remove_item if params[:remove_item]
    redirect_to :action => 'checkout' and return if params[:checkout]
    flash[:notice] = 'Basket updated'
    redirect_to :action => 'index'
  end
  
  def checkout
    redirect_to :action => 'index' and return if @basket.basket_items.empty?

    @address = nil
    @address = Address.find_by_id(session[:address_id]) if session[:address_id]
    @address = Address.new if @address.nil?
  end

  def place_order
    # Delete previous unpaid order, if any
    if session[:order_id] && @order = Order.find_by_id(session[:order_id])
      @order.destroy if @order.status == Order::WAITING_FOR_PAYMENT
    end

    @order = Order.new
    @order.website_id = @w.id
    @order.user_id = @current_user.id if logged_in?
    @order.copy_address @address
    @basket.basket_items.each do |i|
      @order.order_lines << OrderLine.new(
        :product_id => i.product.id,
        :product_sku => i.product.sku,
        :product_name => i.product.name,
        :product_price => i.product.price,
        :tax_amount => 0,
        :quantity => i.quantity,
        :line_total => i.product.price * i.quantity,
        :feature_descriptions => i.feature_descriptions
      )
    end
    @order.status = Order::WAITING_FOR_PAYMENT
    @order.shipping_method = 'Standard Shipping'
    @order.save!
    session[:order_id] = @order.id
    redirect_to :controller => 'orders', :action => 'select_payment_method'
  end
  
  def purge_old
    Basket.purge_old
    flash[:notice] = 'Old baskets purged.'
    redirect_to :action => 'index'
  end
  
  protected

  # Creates an array of FeatureSeletions based on the form input from
  # adding an item to the basket.
  # It will set flash[:notice] if it encounters any errors.
  def get_feature_selections
    f_selections = Array.new
    unless params[:feature].nil?
      params[:feature].each_pair do |feature_id, value|
        puts feature_id + ': ' + value
        feature = Feature.find(feature_id)
        f_selection = FeatureSelection.new
        f_selection.feature_id = feature.id
        case feature.ui_type
        when Feature::TEXT_FIELD
          f_selection.customer_text = value
          if value.empty? and feature.required?
            flash[:notice] = 'Please specify: ' + feature.name
            return
          end
        end
        f_selections << f_selection
      end
    end
    f_selections
  end

  # get valid delivery address or send user back to checkout
  def require_delivery_address
    @address = session[:address_id] ? Address.find_by_id(session[:address_id]) : nil
    redirect_to :action => 'checkout' if @address.nil?
  end

  def remove_item
    params[:remove_item].each_key do |id|
      BasketItem.destroy_all(:id => id, :basket_id => @basket.id)
    end
  end

  def update_quantities
    params[:qty].each_pair do |id,new_qty|
      new_qty = new_qty.to_i
      item = BasketItem.find_by_id_and_basket_id(id, @basket.id)
      if item
        if new_qty == 0
          item.destroy
        elsif new_qty > 0
          item.quantity = new_qty
          item.save
        end
      end
    end
  end

  def find_basket
    if session[:basket_id]
      @basket = Basket.find_by_id(session[:basket_id])
      create_basket if @basket.nil?
    else
      create_basket
    end
  end

  def create_basket
    @basket = Basket.new
    @basket.save
    session[:basket_id] = @basket.id
  end
end