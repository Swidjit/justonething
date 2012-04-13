class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_time_zone

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, :alert => exception.message
  end

  def set_time_zone
    Time.zone = 'Eastern Time (US & Canada)'
  end

  def item_path(item)
    if item.class == Item
      super.item_path
    else
      send("#{item.class.underscore}_path",item)
    end
  end

  def item_url(item)
    if item.class == Item
      super.item_path
    else
      send("#{item.class.underscore}_url",item)
    end
  end

  def render_paginated_feed( html_layout )
    total_entries = Item.count_by_subquery(@feed_items)
    @feed_items = @feed_items.paginate(:page => params[:page], :total_entries => total_entries)
    respond_to do |f|
      f.html { render html_layout }
      f.js { render :partial => 'items/item', :collection => ItemDecorator.decorate(@feed_items) }
    end
  end
end
