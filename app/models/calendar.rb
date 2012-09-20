class Calendar
  
  attr_accessor :from, :to, :filter, :user
  
  def self.upcoming_events(options=nil)
    #community, user, city, ability = options[:community], options[:user], options[:city], options[:ability]
    now = Time.now
    options.merge! from: now, to: (now + 2.weeks)
    options.merge!(user_created: true) if options.key?(:user)
    options.merge!(community_created: true) if options.key?(:community)
    calendar = Calendar.new options
    calendar.events[0..3]
  end
  
  def initialize(options={})
    @community, @from, @to, @filter, @user, @current_user = options[:community], options[:from], options[:to], options[:filter], options[:user], options[:current_user]
    @city, @ability, @ical, @user_created, @community_created = options[:city], options[:ability], options[:ical], options[:user_created], options[:community_created]
  end
  
  def to_ics
    calendar = Icalendar::Calendar.new
    ical_events.each do |event|
      calendar.add_event event.to_ics
    end
    calendar.publish
    calendar.to_ical
  end
  
  def events
    return @events if @events
    @events = @ical ? Event.order(:start_datetime) : Event.reorder('').between(from, to)
    @events = @events.where(user_id: @user.id) if @user and @user_created
    @events = @events.access_controlled_for(@current_user, @city, @ability) # if @city and @user
    @events = @events.having_tag_with_name(@filter) if @filter.present?
    @events = @events.within_community(@community) if @community and @community_created
    @events = @events.includes(:user).where active: true
    @events = @events.map {|event| event.occurrences_between(from, to)}.flatten.sort_by(&:start_datetime) unless @ical
  end
  
  def user_events
    return @user_events if @user_events
    if user.blank? or events.blank?
      @user_events = []
    else
      my_events = Event.owned_or_bookmarked_by_or_rsvp_to(@current_user).where(id: events.map(&:id)).inject({}) { |h, event| h[event.id]=true; h }
      @user_events = events.select { |event| my_events[event.id] }
    end
  end
  
  def date_display
    "#{from.to_s(:short)} to #{to.to_s(:short)}"
  end
  
  def previous_week
    (@from - 1.week).beginning_of_week(:sunday)
  end
  
  def beginning_of_previous_week
    previous_week.to_s(:ymd)
  end
  
  def end_of_previous_week
    (previous_week + 6.days).to_s(:ymd)
  end
  
  def next_week
    (@from + 1.week).beginning_of_week(:sunday)
  end
  
  def beginning_of_next_week
    next_week.to_s(:ymd)
  end
  
  def end_of_next_week
    (next_week + 6.days).to_s(:ymd)
  end
  
end