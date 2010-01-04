class ChoicesController < ApplicationController
  before_filter :find_choice, :except => [:new, :create]
  
  def new
    @choice = Choice.new
    @choice.feature_id = params[:feature_id]
    redirect_to products_path and return unless feature_valid?
  end
  
  def edit
  end
  
  def update
  end
  
  def create
    @choice = Choice.new(params[:choice])
    redirect_to products_path and return unless feature_valid?

    if @choice.save
      flash[:notice] = "Successfully added new choice."
      redirect_to edit_feature_path(@choice.feature)
    else
      render :action => "new"
    end
  end
  
  def destroy
    redirect_to products_path and return unless feature_valid?
    @choice.destroy
    flash[:notice] = "Choice deleted."
    redirect_to edit_feature_path(@choice.feature)
  end
  
  protected
  
  def find_choice
    @choice = Choice.find(params[:id])
    if @choice.feature.product.website_id != @w.id
      render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found"
    end
  end

  def feature_valid?
    @feature = Feature.find_by_id(@choice.feature_id)
    if @feature && @feature.product.website_id == @w.id
      true
    else
      flash[:notice] = 'Invalid feature.'
      false
    end
  end
end