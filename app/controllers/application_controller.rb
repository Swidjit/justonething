class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!, :set_time_zone

  def set_time_zone
    Time.zone = 'Eastern Time (US & Canada)'
  end
end
