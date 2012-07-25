class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate
  before_filter :set_time_zone
  before_filter :set_most_recent_city

  helper_method :current_city

  rescue_from CanCan::AccessDenied do |exception|
    if current_user.present?
      redirect_to root_path, :alert => exception.message
    else
      redirect_to new_user_session_path, :alert => exception.message
    end
  end

  def current_city
    @current_city ||= City.find_by_url_name(params[:city_url_name] || session[:most_recent_city]) || (current_user && current_user.cities.first) || City.first
  end

  def set_most_recent_city
    session[:most_recent_city] = current_city.url_name
  end

  def set_time_zone
    Time.zone = 'Eastern Time (US & Canada)'
  end

  def item_id_from_slug(slug)
    slug.split('-').last
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
    # sometimes @feed_items is an array of objects, and does not require additional counting
    @feed_items.reset
    total_entries = @feed_items.is_a?(Array) ? @feed_items.length : Item.count_by_subquery(@feed_items)
    @taglist = Tag.find(:all,
                        :select => 'tags.name, count(tags.name) as tag_count',
                        :conditions => ['items.id in (?)', @feed_items.collect(&:id)],
                        :joins => 'INNER JOIN "items_tags" ON "items_tags"."tag_id" = "tags"."id" INNER JOIN "items" ON "items"."id" = "items_tags"."item_id"',
                        :order => 'count(tags.name) DESC, tags.name',
                        :limit => '20',
                        :group => 'tags.name')
    if total_entries > 0
      @feed_items = @feed_items.paginate(:page => params[:page], :total_entries => total_entries)
      respond_to do |f|
        f.html { render html_layout }
        f.js { render :partial => 'items/item', :collection => ItemDecorator.decorate(@feed_items) }
      end
    else
      render html_layout
    end
  end

  def default_url_options
    { :city_url_name => current_city.url_name }
  end

  def authenticate
    if request.subdomains.any? and request.subdomains.first != 'www'
      if Rails.env == 'production'
        authenticate_or_request_with_http_basic do |username, password|
          username == "swidjit" && password == "kolket"
        end
      end
    end
  end


end
