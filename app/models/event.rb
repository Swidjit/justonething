class Event < Item
  attr_accessible :cost, :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time
  validates_presence_of :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time
  attr_accessor :start_time, :start_date, :end_time, :end_date

  def self.datetimepicker_to_datetime(datetime_value)
    if datetime_value.is_a?(String)
      Time.strptime(datetime_value.strip,'%m/%d/%Y %l:%M %P')
    else
      datetime_value
    end
  end
end
