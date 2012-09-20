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

    @user = params[:user_id] ? User.find(params[:user_id]) : current_user

    calendar_options = { 
      from: @from, 
      to: @to, 
      filter: params[:filter], 
      user: @user, 
      current_user: current_user, 
      city: current_city, 
      ability: current_ability,
    }

    calendar_options.merge!(user_created: true) if params[:user_id]
    if params[:community_id]
      @community = Community.find params[:community_id]
      calendar_options.merge!(community: @community, community_created: true)
    end

    respond_to do |format|
      format.html {
        @calendar = Calendar.new calendar_options
        @filter = params[:filter]
        @calendar_title = if @community
                            "#{@community.name}'s"
                          elsif params[:user_id].present?
                            "#{@user.display_name}'s"
                          else
                            @current_city.name
                          end
        @calendar_title << " Events Calendar"
        @title = @calendar_title
        @events = @calendar.events
        @user_events = @calendar.user_events
        @item_preset_tags = ItemPresetTag.where(item_type: Event.to_s)
      }
      format.ics {
        calendar_options.merge! ical: true
        @calendar = Calendar.new calendar_options
        render :text => @calendar.to_ics
      }
    end
    
  end
  
  def resource_path(options={})
    params[:user_id] ? user_calendar_path(params[:user_id], options) : calendar_path(options)
  end
  helper_method :resource_path

end
