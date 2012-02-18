class Event < Item
  attr_accessible :cost, :location, :start_time, :end_time
  validates_presence_of :location, :start_time, :end_time
end
