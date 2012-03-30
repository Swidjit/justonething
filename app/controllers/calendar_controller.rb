class CalendarController < ApplicationController
  before_filter :load_events_and_preset_tags

  def index
  end

  def show
    render :index
  end

private

  def load_events_and_preset_tags
    day, month, year = params[:day], params[:month], params[:year]

    if month.present? && day.present? && year.present?
      events = Event.for_date(Date.civil(year.to_i, month.to_i, day.to_i))
    else
      events = Event.for_week(params[:week_no].to_i || 0)
    end

    @events = events.all
    @user_events = current_user.present? ? events.owned_or_bookmarked_by(current_user).all : nil
    @item_preset_tags = ItemPresetTag.where(:item_type => Event.to_s)
  end
end
