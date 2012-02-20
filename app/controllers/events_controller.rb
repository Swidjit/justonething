class EventsController < ApplicationController
  respond_to :html
  authorize_resource :only => [:destroy, :edit, :update]
  before_filter :load_decorated_resource, :only => [:show,:edit,:update]
  before_filter :convert_times_to_db_format, :only => [:create,:update]

  def show
  end

  def new
    @event = EventDecorator.new Event.new
  end

  def create
    @event = Event.new(params[:event])
    @event.user ||= current_user
    @event.save
    respond_with @event
  end

  def edit
  end

  def update
    @event.update_attributes(params[:event])
    respond_with @event
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    flash[:notice] = "Event successfully deleted."
    if request.referer == event_url(params[:id])
      redirect_to root_path
    else
      redirect_to :back
    end
  end

  private
  def convert_times_to_db_format
    params[:event][:start_time] = Event.datetimepicker_to_datetime(params[:event][:start_time])
    params[:event][:end_time] = Event.datetimepicker_to_datetime(params[:event][:end_time])
  end

  def load_decorated_resource
    @event = EventDecorator.find(params[:id])
  end
end