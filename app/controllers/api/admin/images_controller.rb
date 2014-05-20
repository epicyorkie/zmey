class Api::Admin::ImagesController < Api::Admin::AdminController
  def index
    @images = website.images
    render nothing: true, status: 404 if @images.empty?
  end

  def create
    @image = Image.new(image_params)
    io = StringIO.new(Base64.decode64(params[:image][:data]))
    @image.image = io
    @image.website = website
    unless @image.save
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

  def delete_all
    website.images.destroy_all
    render nothing: :true, status: 204
  end

  private

    def image_params
      params.require(:image).permit(:name)
    end
end
