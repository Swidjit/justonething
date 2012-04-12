class Admin::ItemsController < Admin::ApplicationController
  before_filter :load_items, :only => :flagged
  before_filter :load_item, :only => :disable

  def flagged
  end

  def disable
    @item.disable!
    redirect_to :back
  end

private

  def load_items
    @items = Item.flagged.all
  end

  def load_item
    @item = Item.find(params[:item_id])
  end
end
