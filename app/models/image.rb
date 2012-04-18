class Image < ActiveRecord::Base
  # ------------------------------------------------------------------------
  # Virtual & Protected Attributes

  image_accessor  :file # Provided by Dragonfly for image file handling.
  attr_accessible :file

  # ------------------------------------------------------------------------
  # Validations

  validates_presence_of :file
end
