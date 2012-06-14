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
  before_update :update_rule_expirations, if: :rules_need_updating?
  
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
  
  def is_recurring?
    rule.present?
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
  
  
  def next_occurrence
    if rule.present?
      rules.next_occurrence
    else
      start_datetime
    end
  end
  

private

  def start_datetime_in_future
    errors.add(:start_date, "must be not have already passed") if start_datetime.present? && start_datetime < DateTime.now
  end
  
  def init_rules
    self.rules ||= fresh_schedule
  end
  
  def fresh_schedule
    duration = end_datetime ? (end_datetime - start_datetime) : 3600
    IceCube::Schedule.new(start_datetime || Time.now, end_time: expires_on, duration: duration)
  end
  
  def write_rules
    if @set_rule
      case @set_rule
      when 'daily' then add_daily_rule!
      when 'weekly' then add_weekly_rule!
      when 'monthly' then add_monthly_rule!
      end
    end
  end
  
  def rules_need_updating?
    is_recurring? and (start_datetime_changed? or end_datetime_changed? or expires_on_changed?)
  end
  
  def update_rule_expirations
    self.rules.end_time   = expires_on
    self.rules.start_time = start_datetime
    self.rule.until expires_on
  end
  
  # be sure not to remove exception dates when we get there
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
  
  
  
end
