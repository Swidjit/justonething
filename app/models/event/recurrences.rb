module Event::Recurrences

  extend ActiveSupport::Concern
  include IceCube

  included do

    attr_reader :schedule
    attr_writer :weekly_day, :monthly_week, :monthly_day, :monthly_date #, :times
    before_validation :write_rules
    before_update :update_rule_expirations, if: :rules_need_updating?
    after_initialize :unserialize_schedule
    before_save :serialize_schedule

  end
  
  def is_recurring?
    schedule && rule.present?
  end
    
  def is_recurrence!
    @is_recurrence = true
  end
    
  def is_recurrence?
    @is_recurrence
  end

  def is_daily?
    rule.is_a? DailyRule
  end

  def is_weekly?
    rule.is_a? WeeklyRule
  end

  def is_monthly_week?
    rule.is_a?(MonthlyRule) && rule.to_hash[:validations].key?(:day_of_week)
  end
  
  def is_monthly_date?
    rule.is_a?(MonthlyRule) && rule.to_hash[:validations].key?(:day_of_month)
  end
  
  def monthly_date
    rule = get_monthly_date_rule
    rule ? get_monthly_date_rule.first.to_i : mday
  end

  def monthly_day
    rule = get_monthly_rule
    rule ? rule.keys.first.to_i : wday
  end

  def monthly_week
    rule = get_monthly_rule
    rule ? rule.values.first.first.to_i : wmonth
  end
    
  def rule=(value)
    @set_rule = value
  end

  def rule
    schedule.rrules.first
  end
  
  def mday
    start_datetime.andand.mday
  end

  def weekly_day
    is_weekly? ? rule.to_hash[:validations][:day][0] : wday
  end
  
  def wday
    start_datetime.andand.wday.to_i
  end
  
  def wmonth
    start_datetime ? ((start_datetime.mday / 7) + 1).to_i : nil
  end

  def clear_exceptions
    schedule.exception_times.each { |rule|
      schedule.remove_exception_time rule
    }
  end
    
    
  private
    
  def add_daily_rule!
    add_rule Rule.daily
  end

  def add_monthly_date_rule!
    add_rule Rule.monthly.day_of_month(@monthly_date.to_i)
  end

  def add_monthly_week_rule!
    @monthly_day ||= start_datetime.stftime("%u")
    @monthly_week ||= (start_datetime.mday.to_f / 7.to_f).ceil
    day = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday].at(@monthly_day.to_i - 1)
    add_rule Rule.monthly.day_of_week day => [@monthly_week.to_i]
  end
  
  def add_weekly_rule!
    @weekly_day ||= start_datetime.stftime("%u")
    add_rule Rule.weekly(1).day(@weekly_day.to_i)
  end
    
  def add_rule(rule)
    clear_rules!
    rule.until(expires_on.to_time) if expires_on.present?
    schedule.add_recurrence_rule rule
  end

  # be sure not to remove exception dates when we get there
  def clear_rules!
    return if rules.blank?
    schedule.rrules.each do |rule|
      schedule.remove_recurrence_rule rule
    end
  end
  
  def unserialize_schedule
    @schedule = (rules.blank? or rules == "--- \n") ? fresh_schedule : Schedule.from_yaml(rules)
  end
  
  def fresh_schedule
    options = {}
    options.merge!(end_time: expires_on) if expires_on.present?
    options.merge!(duration: duration) if duration.present? and duration > 0
    Schedule.new(start_datetime.andand.utc || Time.now, options)
  end

  def get_monthly_rule
    rule.present? ? rule.to_hash[:validations][:day_of_week] : nil
  end
  
  def get_monthly_date_rule
    rule.present? ? rule.to_hash[:validations][:day_of_month] : nil
  end

  def rules_need_updating?
    is_recurring? and (start_datetime_changed? or end_datetime_changed? or expires_on_changed?)
  end
  
  def serialize_schedule
    self.rules = @schedule.to_yaml if is_recurring?
  end
  
  def write_rules
    if @set_rule
      case @set_rule
      when 'daily' then add_daily_rule!
      when 'weekly' then add_weekly_rule!
      when 'monthly_week' then add_monthly_week_rule!
      when 'monthly_date' then add_monthly_date_rule!
      end
    end
  end

  def update_rule_expirations
    schedule.start_time = start_datetime.utc
    schedule.end_time = expires_on
    schedule.duration = duration
    self.rule.until expires_on
  end

end