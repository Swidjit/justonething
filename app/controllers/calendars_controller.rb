class CalendarsController < ApplicationController

  respond_to :html, :ics

  # TODO: change to have from date and to date instead of week_no or month/day/year
  def show

    if params[:day]
      @from = @to = "#{params[:year]}-#{params[:month]}-#{params[:day]}".to_time
    else
      @from = params[:from] ? Time.parse(params[:from]) : Time.now.beginning_of_week(:sunday)
      @to   = params[:to] ? Time.parse(params[:to]) : @from.end_of_day + 6.days
    end

    respond_to do |format|
      format.html {
        @calendar = Calendar.new from: @from, to: @to, filter: params[:filter], user: current_user, city: current_city, ability: current_ability
        @filter = params[:filter]
        @calendar_title = "#{@current_city.name} Events Calendar"
        @events = @calendar.events
        @user_events = @calendar.user_events
        @item_preset_tags = ItemPresetTag.where(item_type: Event.to_s)
      }
      format.ics {
        @calendar = Calendar.new ical: true, filter: params[:filter], user: current_user, city: current_city, ability: current_ability
        render :text => @calendar.to_ics
      }
    end
    
  end

end
