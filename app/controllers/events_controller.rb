class EventsController < ItemsController
  before_filter :convert_times_to_db_format, :only => [:create,:update]

  private
  def convert_times_to_db_format
    if params[:event].present?
      if params[:event][:start_date].present? && params[:event][:start_time].present?
        start_date_time = params[:event][:start_date] + ' ' + params[:event][:start_time]
        params[:event][:start_datetime] = Event.datetimepicker_to_datetime(start_date_time,Time.zone)
      end
      if params[:event][:end_date].present? && params[:event][:end_time].present?
        end_date_time = params[:event][:end_date] + ' ' + params[:event][:end_time]
        params[:event][:end_datetime] = Event.datetimepicker_to_datetime(end_date_time,Time.zone)
      end
    end
  end

  def item_class
    Event
  end
end