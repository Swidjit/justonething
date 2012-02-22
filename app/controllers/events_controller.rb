class EventsController < ItemsController
  before_filter :convert_times_to_db_format, :only => [:create,:update]

  private
  def convert_times_to_db_format
    params[:event][:start_time] = Event.datetimepicker_to_datetime(params[:event][:start_time])
    params[:event][:end_time] = Event.datetimepicker_to_datetime(params[:event][:end_time])
  end

  def item_class
    Event
  end
end