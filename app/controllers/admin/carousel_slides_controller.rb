class Admin::CarouselSlidesController < ApplicationController
  layout 'admin'
  before_action :admin_or_manager_required
  before_action :find_carousel_slide, only: [:edit, :update, :destroy]

  def index
    @carousel_slides = @w.carousel_slides
  end

  def new
    @carousel_slide = CarouselSlide.new
  end

  def edit
  end

  def create
    @carousel_slide = CarouselSlide.new(carousel_slide_params)
    @carousel_slide.website_id = @w.id

    if @carousel_slide.save
      redirect_to admin_carousel_slides_path, notice: 'Successfully added new carousel slide.'
    else
      render :new
    end
  end

  def update
    if @carousel_slide.update_attributes(carousel_slide_params)
      redirect_to admin_carousel_slides_path, notice: 'Carousel slide successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @carousel_slide.destroy
    redirect_to admin_carousel_slides_path, notice: 'Carousel slide deleted.'
  end

  protected

  def find_carousel_slide
    @carousel_slide = CarouselSlide.find_by(id: params[:id], website_id: @w.id)
    not_found unless @carousel_slide
  end

  def carousel_slide_params
    params.require(:carousel_slide).permit(:caption, :image_id, :link, :position)
  end
end