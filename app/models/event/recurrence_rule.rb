class Event::RecurrenceRule

  include IceCube

  attr_accessor :rule
  attr_writer :weekly_day, :monthly_week, :monthly_day, :monthly_date
  attr_reader :event

  delegate :start_datetime, to: :event

  def initialize(options={})
    @ice_rule, @rule, @event = options[:ice_rule], options[:rule], options[:event]
    if @rule
      case @rule
        when 'weekly'
          @weekly_day = options[:weekly_day]
        when 'monthly_week'
          @monthly_day = options[:monthly_day]
          @monthly_week = options[:monthly_week]
        when 'monthly_date'
          @monthly_date = options[:monthly_date]
      end
    elsif @ice_rule
      if is_daily?
        @rule = 'daily'
      elsif is_weekly?
        @rule = 'weekly'
        @weekly_day = weekly_day
      elsif is_monthly_week?
        @rule = 'monthly_week'
        @monthly_day = monthly_day
        @monthly_week = monthly_week
      elsif is_monthly_date?
        @rule = 'monthly_date'
        @monthly_date = monthly_date
      end
    end
  end

  def ice_rule
    @ice_rule ||= to_ice_cube
  end

  def to_ice_cube
    if rule.present?
      return case rule
        when 'daily' then as_daily_rule
        when 'weekly' then as_weekly_rule
        when 'monthly_week' then as_monthly_week_rule
        when 'monthly_date' then as_monthly_date_rule
        else as_empty_rule
      end
    else
      return @ice_rule
    end
  end

  def as_empty_rule
    nil
  end

  def as_daily_rule
    Rule.daily
  end

  def as_weekly_rule
    @weekly_day ||= start_datetime.stftime("%u")
    Rule.weekly(1).day(@weekly_day.to_i)
  end

  def as_monthly_week_rule
    @monthly_day ||= start_datetime.stftime("%u")
    @monthly_week ||= (start_datetime.mday.to_f / 7.to_f).ceil
    day = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday].at(@monthly_day.to_i - 1)
    Rule.monthly.day_of_week day => [@monthly_week.to_i]
  end

  def as_monthly_date_rule
    Rule.monthly.day_of_month(@monthly_date.to_i)
  end

  def get_monthly_rule
    ice_rule.present? ? ice_rule.to_hash[:validations][:day_of_week] : nil
  end

  def get_monthly_date_rule
    ice_rule.present? ? ice_rule.to_hash[:validations][:day_of_month] : nil
  end

  def is_empty?
    !ice_rule.present?
  end

  def is_daily?
    ice_rule.present? and ice_rule.is_a? DailyRule
  end

  def is_weekly?
    ice_rule.present? and ice_rule.is_a? WeeklyRule
  end

  def is_monthly_week?
    ice_rule.present? and ice_rule.is_a?(MonthlyRule) && ice_rule.to_hash[:validations].key?(:day_of_week)
  end

  def is_monthly_date?
    ice_rule.present? and ice_rule.is_a?(MonthlyRule) && ice_rule.to_hash[:validations].key?(:day_of_month)
  end

  def monthly_date
    rule = get_monthly_date_rule
    rule ? get_monthly_date_rule.first.to_i : event.mday
  end

  def monthly_day
    rule = get_monthly_rule
    rule ? rule.keys.first.to_i : event.wday
  end

  def monthly_week
    rule = get_monthly_rule
    rule ? rule.values.first.first.to_i : event.wmonth
  end

  def weekly_day
    is_weekly? ? ice_rule.to_hash[:validations][:day][0] : event.wday
  end


end