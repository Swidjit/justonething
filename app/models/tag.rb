class Tag < ActiveRecord::Base
  extend TagClassMethods

  default_scope :conditions => "#{table_name}.type IS NULL"
end
