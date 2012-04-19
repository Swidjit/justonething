class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_time_zone

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, :alert => exception.message
  end

  def current_city
    @current_city ||= City.find_by_url_name(params[:city_url_name]) || current_user.cities.first || City.first
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
    if @feed_items.any?
      @feed_items = @feed_items

      total_entries = Item.count_by_subquery(@feed_items)
      @feed_items = @feed_items.paginate(:page => params[:page], :total_entries => total_entries)
      respond_to do |f|
        f.html { render html_layout }
        f.js { render :partial => 'items/item', :collection => ItemDecorator.decorate(@feed_items) }
      end
    else
      render html_layout
    end
  end

  def url_options
    { :city_url_name => current_city.url_name }.merge(super)
  end

end
