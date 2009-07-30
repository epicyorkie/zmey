class ProductsController < ApplicationController
  before_filter :find_product, :only => [:show, :edit, :update]

  def index
    @products = Product.all
  end
  
  def show
  end
  
  def new
    @product = Product.new
  end
  
  def edit
  end
  
  def create
    @product = Product.new(params[:product])
    @product.website_id = @w

    if @product.save
      flash[:notice] = "Successfully added new product."
      redirect_to :action => "new"
    else
      render :action => "new"
    end
  end
  
  def update
    if @product.update_attributes(params[:product])
      flash[:notice] = 'Product saved.'
      redirect_to product_path(@product)
    else
      render :action => 'edit'
    end
  end

  protected
  
  def find_product
    @product = Product.find(params[:id])
  end

end