class DateTimeDecorator < ApplicationDecorator
  decorates :date_time

  def event_start_time
    return date_time.strftime("%b. %d, %Y @ %I:%M %p")
  end
end
