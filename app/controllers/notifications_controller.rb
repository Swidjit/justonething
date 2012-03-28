class NotificationsController < ApplicationController
  authorize_resource

  def index
    @notifications = current_user.notifications
  end

end
