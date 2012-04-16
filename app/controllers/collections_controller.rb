class CollectionsController < ItemsController

  before_filter :load_feed_items, :only => :show

  private
  def item_class
    Collection
  end

  def load_feed_items
    @feed_items = @item.items
  end
end