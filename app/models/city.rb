class City < ActiveRecord::Base

  attr_accessible :url_name, :display_name

  validates_presence_of :url_name, :display_name
  validates_format_of :url_name, :with => /[a-zA-Z0-9]+/

end
