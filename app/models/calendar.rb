class Calendar
  
  attr_accessor :from, :to, :filter, :user
  
  def self.upcoming_events(user)
    now = Time.now
    calendar = Calendar.new from: now, to: (now + 2.weeks), user: user
    events = user ? calendar.user_events : calendar.events
    events[0..3]
  end
  
  def initialize(options={})
    @from, @to, @filter, @user = options[:from], options[:to], options[:filter], options[:user]
    @from = @from.beginning_of_day
    @to = @to.end_of_day
  end
  
  def events
    return @events if @events
    @events = Event.reorder('').between(from, to) 
    @events = @events.having_tag_with_name(@filter) if @filter.present?
    @events = @events.map {|event| event.occurrences_between(from, to)}.flatten.sort_by(&:start_datetime)
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