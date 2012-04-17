class GeoTag < ActiveRecord::Base
  extend TagClassMethods

  set_table_name :tags
  default_scope :conditions => "#{table_name}.type = 'GeoTag'"

  before_validation :set_type

  has_and_belongs_to_many :items, :uniq => true, :join_table => :items_tags, :foreign_key => :tag_id

private

  def set_type
    self.type = 'GeoTag'
  end
end
