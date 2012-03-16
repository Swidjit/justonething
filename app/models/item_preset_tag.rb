class ItemPresetTag < ActiveRecord::Base

  ITEM_TYPES = %w( Event HaveIt Link Thought WantIt )

  validates :tag, :presence => true, :format => { :with => /^[0-9a-z-]+$/ }
  validates_uniqueness_of :tag, :scope => :item_type
  validates_inclusion_of :item_type, :in => ITEM_TYPES

  attr_accessible :tag, :item_type

end
