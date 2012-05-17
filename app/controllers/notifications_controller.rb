class NotificationsController < ApplicationController
  authorize_resource

  def index
    @notifications = NotificationDecorator.decorate(current_user.notifications)
  end

end
