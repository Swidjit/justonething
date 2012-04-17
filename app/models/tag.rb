class Tag < ActiveRecord::Base
  extend TagClassMethods

  default_scope :conditions => "#{table_name}.type IS NULL"

  has_and_belongs_to_many :items, :uniq => true
end
