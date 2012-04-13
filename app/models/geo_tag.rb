class GeoTag < ActiveRecord::Base
  extend TagClassMethods

  set_table_name :tags
  default_scope :conditions => "#{table_name}.type = 'GeoTag'"

  before_validation :set_type

private

  def set_type
    self.type = 'GeoTag'
  end
end
