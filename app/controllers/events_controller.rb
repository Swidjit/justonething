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
    @event.user ||= current_user
    @event.save
    respond_with @event
  end
end