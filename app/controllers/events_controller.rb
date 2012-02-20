class EventsController < ApplicationController
  respond_to :html

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
end