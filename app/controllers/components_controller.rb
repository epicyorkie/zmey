class ComponentsController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_component, :only => [:edit, :destroy, :update]

  def new
    @component = Component.new
    @component.product_id = params[:product_id]
    redirect_to components_path and return unless product_valid?
  end

  def create
    @component = Component.new(params[:component])
    redirect_to products_path and return unless product_valid?

    if @component.save
      flash[:notice] = "Successfully added new component."
      redirect_to edit_product_path(@component.product)
    else
      render :action => "new"
    end
  end

  def update
    if @component.update_attributes(params[:component])
      flash[:notice] = "Component successfully updated."
      redirect_to edit_product_path(@component.product)
    else
      render :action => "edit"
    end
  end

  def edit
    @features = @component.features.sort {|a,b| b.choices.count <=> a.choices.count}

    num_permutations = 1
    num_features = @features.count
    @choice_array = []
    f_index = 0

    @headings = []

    @rows = []

    require 'pp'

    @features.each do |feature|
      @headings = @headings.unshift(feature.name)
      choices = feature.choices
      num_permutations *= choices.count
      @choice_array[f_index] = []

      choices.each {|choice| @choice_array[f_index] << choice.id}
      f_index += 1
    end

    pp @headings

    pp @choice_array

    puts "num_permutations = #{num_permutations}"

    (0...num_permutations).each do |c_index|
      permutation_array = []
      change = 1
      @rows[c_index] = {}
      @rows[c_index][:choices] = []
      (0...@choice_array.count).each do |f_index|
        permutation_array[f_index] = @choice_array[f_index][(c_index / change) % @choice_array[f_index].count]
        @rows[c_index][:choices] = @rows[c_index][:choices].unshift(Choice.find(permutation_array[f_index]).name)
        change *= @choice_array[f_index].count
      end

      permutation_array.sort!
  		string = ''
  		(0...permutation_array.count).each {|i| string += "_#{permutation_array[i]}_"}
      @rows[c_index][:permutation] = Permutation.find_by_permutation(string)
    end

    pp @rows
  end
  
  def destroy
    @feature.destroy
    flash[:notice] = "Feature deleted."
    redirect_to edit_product_path(@feature.product)
  end

  protected
  
  def find_component
    @component = Component.find(params[:id])
    redirect_to products_path and return unless product_valid?
  end
  
  def product_valid?
    if Product.find_by_id_and_website_id(@component.product_id, @w.id)
      true
    else
      flash[:notice] = 'Invalid product.'
      false
    end
  end
end