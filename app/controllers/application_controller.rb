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
end
