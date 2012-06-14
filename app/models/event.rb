class Event < Item
  attr_accessible :cost, :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time, :rule, :weekly_day, :monthly_week, :monthly_day, :times
  validates_presence_of :location, :start_datetime, :end_datetime
  validates_presence_of :start_date, :start_time, :end_date, :end_time, if: :processing_through_ui?
  attr_accessor :start_time, :start_date, :end_time, :end_date
  attr_writer :weekly_day, :monthly_week, :monthly_day, :times

  has_many :rsvps, :dependent => :destroy, :foreign_key => :item_id
  has_many :rsvp_users, :through => :rsvps, :source => :user
  
  scope :order_by_start_datetime, :order => "start_datetime ASC"

  validate :start_datetime_in_future
  
  serialize :rules, IceCube::Schedule
  after_initialize :init_rules
  before_validation :write_rules
  
  scope :upcoming, lambda {
    { :conditions => ["#{Event.table_name}.start_datetime >= ?", DateTime.now.beginning_of_day] }
  }

  # week is zero-indexed starting with the current day as the first day of the first week
  scope :for_week, lambda { |week| {
    :conditions => ["#{Event.table_name}.start_datetime >= ? AND #{Event.table_name}.start_datetime <= ?",
                    (week * 7).days.from_now.beginning_of_day, ((week + 1) * 7).days.from_now.end_of_day]
  } }

  scope :for_date, lambda { |date| {
    :conditions => ["#{Event.table_name}.start_datetime >= ? AND #{Event.table_name}.start_datetime <= ?", date.beginning_of_day, date.end_of_day]
  } }

  scope :owned_or_bookmarked_by_or_rsvp_to, lambda { |user| {
    :select => "DISTINCT #{Item.table_name}.*",
    :joins => "LEFT JOIN #{Bookmark.table_name} ON #{Bookmark.table_name}.item_id = #{Item.table_name}.id " +
        "LEFT JOIN #{Rsvp.table_name} ON #{Rsvp.table_name}.item_id = #{Item.table_name}.id",
    :conditions => ["#{Item.table_name}.user_id = ? OR
      (#{Rsvp.table_name}.user_id = ? AND #{Rsvp.table_name}.id IS NOT NULL) OR
      (#{Bookmark.table_name}.user_id = ? AND #{Bookmark.table_name}.id IS NOT NULL)", user.id, user.id, user.id]
  } }

  def self.datetimepicker_to_datetime(datetime_value, time_zone)
    if datetime_value.is_a?(String) && datetime_value.present?
      Time.strptime("#{datetime_value.strip} #{time_zone.tzinfo.current_period.abbreviation.to_s}",'%m/%d/%Y %l:%M %P %Z')
    else
      datetime_value
    end
  end
  
  def self.new_from_feed(event, feed)
    return if event.dtstart.to_time < Time.now or event.dtstart.to_time > 1.month.from_now
    user = feed.user
    unless user.items.where(type: 'Event', title: event.summary, start_datetime: event.dtstart.to_time).present?
      e = Event.new
      e.title = event.summary
      e.description = event.description.present? ? event.description : event.summary
      e.start_datetime = event.dtstart.to_time
      e.end_datetime = event.dtend.to_time
      e.location = event.location.present? ? event.location : "Location not given"
      e.user = user
      e.tag_list = feed.tag_list
      e.geo_tag_list= feed.geo_tag_list
      e.save!
    end
    
  end
  
  def rule
    rules.rrules.first
  end
  
  def is_daily?
    rule.is_a? IceCube::DailyRule
  end
  
  def is_weekly?
    rule.is_a? IceCube::WeeklyRule
  end
  
  def is_monthly?
    rule.is_a? IceCube::MonthlyRule
  end
  
  def weekly_day
    is_weekly? ? rule.to_hash[:interval] : nil
  end

  def monthly_day
    rule = get_monthly_rule
    rule ? rule.keys.first.to_i : nil
  end
  
  def monthly_week
    rule = get_monthly_rule
    rule ? rule.values.first.first.to_i : nil
  end
  
  def rule=(value)
    @set_rule = value
  end
  
  def times=(values)
    @set_times = values
  end
  
  class EventTime
    def initialize(params=nil)
      if params
        if params[:start_date].present? && params[:start_time].present?
          start_date_time = params[:start_date] + ' ' + params[:start_time]
          @start_datetime = Event.datetimepicker_to_datetime(start_date_time,Time.zone)
        end
        if params[:end_date].present? && params[:end_time].present?
          end_date_time = params[:end_date] + ' ' + params[:end_time]
          @end_datetime = Event.datetimepicker_to_datetime(end_date_time,Time.zone)
        end
        
      end
    end
    
    def start_date
      start_datetime('date')
    end
    
    def end_date
      end_datetime('date')
    end
    
    def start_time
      start_datetime('time')
    end
    
    def end_time
      end_datetime('time')
    end
    
    def start_datetime(format='datetime')
      @start_datetime.andand.strftime(send("#{format}_format"))
    end
    
    def end_datetime(format='datetime')
      @end_datetime.andand.strftime(send("#{format}_format"))
    end
    
    def valid?
      @start_datetime > Time.now
    end
    
    private

    def date_format
      '%m/%d/%Y'
    end

    def datetime_format
      date_format + ' ' + time_format
    end

    def time_format
      '%l:%M %P'
    end
    
  end
  
  def times
    [EventTime.new]
  end
  

private

  def start_datetime_in_future
    errors.add(:start_date, "must be not have already passed") if start_datetime.present? && start_datetime < DateTime.now
  end
  
  def init_rules
    duration = end_datetime ? (end_datetime - start_datetime) : 3600
    self.rules ||= IceCube::Schedule.new(start_datetime || Time.now, end_time: expires_on, duration: duration)
  end
  
  def write_rules
    if @set_rule
      case @set_rule
      when 'daily' then add_daily_rule!
      when 'weekly' then add_weekly_rule!
      when 'monthly' then add_monthly_rule!
      end
    end
    set_times
  end
  
  def clear_rules!
    rules.rrules.each do |rule|
      self.rules.remove_recurrence_rule rule
    end
  end
  
  def add_rule(rule)
    clear_rules!
    rule.until(expires_on.to_time) if expires_on.present?
    self.rules.add_recurrence_rule rule
  end
  
  def add_daily_rule!
    add_rule IceCube::Rule.daily
  end
  
  def add_weekly_rule!
    @weekly_day ||= start_datetime.stftime("%u")
    add_rule IceCube::Rule.weekly(@weekly_day)
  end
  
  def add_monthly_rule!
    @monthly_day ||= start_datetime.stftime("%u")
    @monthly_week ||= (start_datetime.mday.to_f / 7.to_f).ceil
    day = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday].at(@monthly_day.to_i - 1)
    add_rule IceCube::Rule.monthly.day_of_week day => [@monthly_week]
  end
    
  def get_monthly_rule
    rule.present? ? rule.to_hash[:validations][:day_of_week] : nil
  end
  
  def set_times
    return unless @set_times
    # DO SOMETHING!
  end
  
  
end
