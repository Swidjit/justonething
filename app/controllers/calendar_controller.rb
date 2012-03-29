class CalendarController < ApplicationController
  before_filter :load_events

  def index
  end

  def show
    render :index
  end

private

  def load_events
    if params[:month].present? && params[:day].present? && params[:year].present?
      date = Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      scope = lambda { |event_class| event_class.for_date(date) }
    else
      week = params[:week_no].to_i || 0
      scope = lambda { |event_class| event_class.for_week(week) }
    end

    @events = scope.call(Event).all
    @user_events = current_user.present? ? scope.call(Event).owned_or_bookmarked_by(current_user).all : nil
  end
end
