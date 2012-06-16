class EventsController < ItemsController
  before_filter :convert_times_to_db_format, :only => [:create,:update]
  
  def show
    if params[:date]
      begin
        @event_date = Date.parse params[:date]
        if @item.is_recurring? and @item.occurs_on? @event_date
          @item.model = @item.model.to_occurrence(@event_date)
        end
      rescue ArgumentError
      end
    end
  end
  
  def destroy
    if params[:date]
      @item.cancel_occurrence(params[:date])
      flash[:notice] = "The event was cancelled."
    else
      @item.delete
      flash[:notice] = "The event was successfully deleted."
    end
    # if deleted from show go to root else go back to feed
    if request.referer == send("#{item_class.to_s.underscore}_url",params[:id])
      redirect_to root_path
    else
      redirect_to :back
    end
  end
  
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