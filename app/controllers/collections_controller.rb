class CollectionsController < ItemsController
  authorize_resource :only => :add_item

  before_filter :load_feed_items, :only => :show

  def show
    render_paginated_feed :show
  end

  def add_item
    item = Item.find(params[:item_id])
    collection = Collection.find(item_id_from_slug(params[:id]))
    if can? :manage, collection
      collection.items << item
      flash[:notice] = 'Successfully added item to collection'
    else
      flash[:error] = 'You do not have permission to manage this collection'
    end
    redirect_to :back
  end

  private
  def item_class
    Collection
  end

  def load_feed_items
    @feed_items = @item.items
  end
end
