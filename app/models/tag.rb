class Tag < ActiveRecord::Base

  validates :name, :presence => true, :uniqueness => true, :format => { :with => /^[^\/]+$/ }

  has_and_belongs_to_many :items, :uniq => true

end
