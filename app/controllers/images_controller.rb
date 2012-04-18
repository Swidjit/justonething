class ImagesController < ApplicationController
  # ajaxupload.js doesn't currently include the Rails CSRF meta
  # tag in its request.
  protect_from_forgery :except => :generate

  def generate
    param_with_file = params["image_param"]
    file = params[param_with_file]

    @image = Image.create(:file => file)
    render json: ImageDecorator.new(@image).to_json('150x150>')
  end
end