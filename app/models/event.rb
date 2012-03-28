class Event < Item
  attr_accessible :cost, :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time
  validates_presence_of :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time
  attr_accessor :start_time, :start_date, :end_time, :end_date
  
  scope :for_week, lambda { |week| {
    :conditions => ["#{Event.table_name}.start_datetime >= ? AND #{Event.table_name}.start_datetime <= ?",
                    (week * 7).days.from_now.beginning_of_day, ((week + 1) * 7).days.from_now.end_of_day]
  } }

  def self.datetimepicker_to_datetime(datetime_value)
    if datetime_value.is_a?(String)
      Time.strptime(datetime_value.strip,'%m/%d/%Y %l:%M %P')
    else
      datetime_value
    end
  end

end
