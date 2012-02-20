class EventDecorator < ItemDecorator
  decorates :event

  def cost
    event.cost || 'Free'
  end

  def start_time
    event.start_time.strftime(time_format)
  end

  def end_time
    event.end_time.strftime(time_format)
  end

  private
  def time_format
    '%m/%d/%Y %l:%M %P'
  end
end