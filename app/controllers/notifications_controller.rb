class NotificationsController < ApplicationController
  authorize_resource

  def index
    Rails.logger.debug('Hitting index')
    @notifications = NotificationDecorator.decorate(current_user.notifications)
    Rails.logger.debug @notifications.inspect
  end

end
