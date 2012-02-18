class EventDecorator < ItemDecorator
  decorates :event

  def cost
    event.cost || 'Free'
  end

end