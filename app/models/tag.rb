class Tag < ActiveRecord::Base

  validates :name, :presence => true, :uniqueness => true, :format => { :with => /^[0-9a-z-]+$/ }

  has_and_belongs_to_many :items, :uniq => true

end
