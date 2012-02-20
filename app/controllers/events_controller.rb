class EventsController < ApplicationController
  respond_to :html
  authorize_resource :only => :destroy

  def show
    @event = EventDecorator.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(params[:event])
    @event.start_time = Event.datetimepicker_to_datetime(params[:event][:start_time])
    @event.end_time = Event.datetimepicker_to_datetime(params[:event][:end_time])
    @event.user ||= current_user
    @event.save
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
end