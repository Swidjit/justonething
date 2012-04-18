# http://markevans.github.com/dragonfly/file.Rails3.html
require 'dragonfly'

app = Dragonfly[:images]
app.configure_with :imagemagick
app.configure_with :rails

if Rails.env.production?
  app.configure do |config|
    config.datastore = Dragonfly::DataStorage::S3DataStore.new(
      :bucket_name       => ENV['S3_BUCKET'],
      :access_key_id     => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    )
  end
end

app.define_macro(ActiveRecord::Base, :image_accessor)