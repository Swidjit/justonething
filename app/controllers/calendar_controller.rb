class CalendarController < ApplicationController
  before_filter :load_events_and_preset_tags

  def index
  end

  def show
    render :index
  end

private

  def load_events_and_preset_tags
    day, month, year, week = params[:day], params[:month], params[:year], params[:week_no]

    if month.present? && day.present? && year.present?
      events = Event.for_date(Date.civil(year.to_i, month.to_i, day.to_i))
    else
      events = Event.for_week(week.to_i || 0)
    end

    events = events.having_tag_with_name(params[:filter]) if params[:filter].present?

    @events = events.all
    @user_events = current_user.present? ? events.owned_or_bookmarked_by(current_user).all : nil
    @item_preset_tags = ItemPresetTag.where(:item_type => Event.to_s)
  end
end
