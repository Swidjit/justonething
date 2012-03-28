class CalendarController < ApplicationController
  before_filter :load_events

  def index
  end

private

  def load_events
    week = params[:id] || 0
    @events = Event.for_week(week).all
    @user_events = Event.for_week(week).owned_or_bookmarked_by(current_user).all
  end
end
