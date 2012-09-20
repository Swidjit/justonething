module Event::Recurrences

  extend ActiveSupport::Concern
  include IceCube

  included do

    attr_reader :schedule, :rules
    before_validation :add_recurrence_rules
    #before_validation :add_recurrence_times
    after_initialize :unserialize_schedule
    after_validation :serialize_schedule

  end

  def rule_description
    schedule.rrules.map(&:to_s).to_sentence
  end

  def is_recurring?
    schedule && (rules.present? or times.present?)
  end
    
  def is_recurrence!
    @is_recurrence = true
  end
    
  def is_recurrence?
    @is_recurrence
  end

  def mday
    start_datetime.andand.mday
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

  def clear_rules!
    schedule.rrules.each do |rule|
      schedule.remove_recurrence_rule rule
    end
  end
  
  def times
    @times ||= schedule.present? ? (schedule.recurrence_times - [start_datetime]).map {|time| RecurrenceTime.new time } : []
  end
  
  def times=(values)
    @times = []
    values.each do |value|
      if value[:start_date].present? and value[:start_time].present?
        start_date_time = value[:start_date] + ' ' + value[:start_time]
        @times << Event.datetimepicker_to_datetime(start_date_time,Time.zone)
      end
    end
    
  end

  def empty_rule
    Event::RecurrenceRule.new event: self
  end

  class RecurrenceTime
    attr_accessor :start_date, :start_time
    def initialize(time)
      @start_date = time.strftime '%m/%d/%Y'
      @start_time = time.strftime '%l:%M %P'
    end
  end

  def rules=(values)
    @rules = []
    values.each do |k, rule_params|
      rule_params[:event] = self
      rule = Event::RecurrenceRule.new rule_params
      iced_rule = rule.to_ice_cube
      if iced_rule.present?
        @rules << rule
      end
    end
  end


  private
    
  # be sure not to remove exception dates when we get there
  def unserialize_schedule
    ice_rules = read_attribute 'rules'
    begin
      @schedule = (ice_rules.blank? or ice_rules == "--- \n") ? Schedule.new : Schedule.from_yaml(ice_rules)
      @rules = @schedule.rrules.map { |item| Event::RecurrenceRule.new ice_rule: item, event: self }
      @extimes = @schedule.extimes
      @times = @schedule.rtimes
    rescue TypeError
      @rules, @extimes, @times = [], [], []
      @schedule = Schedule.new
    end
  end
  
  def serialize_schedule
    write_attribute 'rules', @schedule.to_yaml
  end

  def add_recurrence_rules

    @schedule = Schedule.new
    @schedule.start_time = start_datetime
    @schedule.end_time = expires_on.to_time if expires_on.present?
    @schedule.duration = duration

    @rules.each { |rule| @schedule.add_recurrence_rule rule.to_ice_cube } if @rules.present?
    @extimes.each { |time| @schedule.add_exception_time(time) } if @extimes.present?
    @times.each { |time| @schedule.add_recurrence_time time } if @times.present?

    if expires_on.present? or expires_on_changed?
      @schedule.rrules.each do |rule|
        rule.until expires_on.to_time
      end
    end

    true
  end

end