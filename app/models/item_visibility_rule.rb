class ItemVisibilityRule < ActiveRecord::Base

  validates_presence_of :visibility_id, :visibility_type, :item_id

  belongs_to :visibility, :polymorphic => true
  belongs_to :item

end
