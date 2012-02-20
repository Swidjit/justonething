class Event < Item
  attr_accessible :cost, :location, :start_time, :end_time
  validates_presence_of :location, :start_time, :end_time

  def self.datetimepicker_to_datetime(datetime_value)
    if datetime_value.is_a?(String)
      Time.strptime(datetime_value,'%m/%d/%Y %l:%M %P')
    else
      datetime_value
    end
  end
end
