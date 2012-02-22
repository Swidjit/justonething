class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_time_zone

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, :alert => exception.message
  end

  def authorize_create_item
    authorize! :create, Item
  end

  def set_time_zone
    Time.zone = 'Eastern Time (US & Canada)'
  end
end
