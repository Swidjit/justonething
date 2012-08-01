class Calendar
  
  attr_accessor :from, :to, :filter, :user
  
  def self.upcoming_events(user=nil)
    now = Time.now
    calendar = Calendar.new from: now, to: (now + 2.weeks), user: user
    events = user ? calendar.user_events : calendar.events
    events[0..3]
  end
  
  def initialize(options={})
    @from, @to, @filter, @user, @city, @ability, @ical = options[:from], options[:to], options[:filter], options[:user], options[:city], options[:ability], options[:ical]
    # unless @ical
    #   @from = @from.beginning_of_day
    #   @to = @to.end_of_day
    # end
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
    @events = @events.access_controlled_for(@user, @city, @ability) if @city and @user
    @events = @events.having_tag_with_name(@filter) if @filter.present?
    @events = @events.includes(:user).where active: true
    @events = @events.map {|event| event.occurrences_between(from, to)}.flatten.sort_by(&:start_datetime) unless @ical
  end
  
  def user_events
    return @user_events if @user_events
    if user.blank? or events.blank?
      @user_events = []
    else
      my_events = Event.owned_or_bookmarked_by_or_rsvp_to(@user).where(id: events.map(&:id)).inject({}) { |h, event| h[event.id]=true; h }
      @user_events = events.select { |event| my_events[event.id] }
    end
  end
  
  def date_display
    "#{from.to_s(:short)} to #{to.to_s(:short)}"
  end
  
  def beginning_of_previous_week
    (@from - 1.week).beginning_of_week.to_s(:ymd)
  end
  
  def end_of_previous_week
    (@from - 1.week).end_of_week.to_s(:ymd)
  end
  
  def beginning_of_next_week
    (@from + 1.week).beginning_of_week.to_s(:ymd)
  end
  
  def end_of_next_week
    (@from + 1.week).end_of_week.to_s(:ymd)
  end
  
end