class ImageDecorator < ApplicationDecorator
  decorates :image

  def thumb(size='150x150>',options={})
    h.image_tag(thumb_url(size),options)
  end

  def to_json(size=nil)
    {
      :id  => id,
      :url => size ? thumb_url(size) : full_size_url
    }.to_json
  end

  # -----------------------------------------------------------------
  private

  # Proxy to the Dragonfly #thumb method which takes an
  # imagemagick-formatted string.
  #
  # http://markevans.github.com/dragonfly/file.ImageMagick.html
  #
  def thumb_url(size)
    image.file.thumb(size).url
  end

  def full_size_url
    image.file.url
  end
end