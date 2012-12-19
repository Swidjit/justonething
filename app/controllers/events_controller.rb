class EventsController < ItemsController
  before_filter :convert_times_to_db_format, :only => [:create,:update]
  
  def show
    if params[:date]
      begin
        @event_date = Date.parse params[:date]
        if @item.is_recurring?
          if @item.occurs_on? params[:date]
            @item.model = @item.model.to_occurrence(@event_date)
          else
            render('errors/404', :status => 404) and return
          end
        end
      rescue ArgumentError
      end
    end
    respond_to do |format|
      format.html
      format.ics { render text: @item.to_ics(standalone: true) }
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
      redirect_to profile_path(current_user.display_name)
    end
  end
  
  
  def convert_times_to_db_format
    if params[:item].present?
      if params[:item][:start_date].present? && params[:item][:start_time].present?
        start_date_time = params[:item][:start_date] + ' ' + params[:item][:start_time]
        params[:item][:start_datetime] = Event.datetimepicker_to_datetime(start_date_time,Time.zone)
      end
      if params[:item][:end_date].present? && params[:item][:end_time].present?
        end_date_time = params[:item][:end_date] + ' ' + params[:item][:end_time]
        params[:item][:end_datetime] = Event.datetimepicker_to_datetime(end_date_time,Time.zone)
      end
    end
  end

  def item_class
    Event
  end

end