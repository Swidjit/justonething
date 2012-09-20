module Event::Recurrences

  extend ActiveSupport::Concern
  include IceCube

  included do

    attr_reader :schedule, :rules
    #before_validation :add_recurrence_rules
    before_validation :add_recurrence_times
    after_initialize :unserialize_schedule
    before_save :serialize_schedule

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
    @schedule = fresh_schedule if new_record?
    @rules = []
    clear_rules!
    values.each do |k, rule_params|
      rule_params[:event] = self
      rule = Event::RecurrenceRule.new rule_params
      iced_rule = rule.to_ice_cube
      if iced_rule.present?
        @schedule.add_recurrence_rule iced_rule
        @rules << rule
      end
    end
  end


  private
    
  # be sure not to remove exception dates when we get there
  def unserialize_schedule
    ice_rules = read_attribute 'rules'
    begin
      @schedule = (ice_rules.blank? or ice_rules == "--- \n") ? fresh_schedule : Schedule.from_yaml(ice_rules)
      @rules = @schedule.rrules.map { |item| Event::RecurrenceRule.new ice_rule: item, event: self }
    rescue TypeError
      @rules = []
      @schedule = fresh_schedule
    end
  end
  
  def fresh_schedule
    Schedule.new
  end

  def serialize_schedule
    if @rules.present? or @times.present?
      update_rule_expirations!
      write_attribute 'rules', @schedule.to_yaml
    end
  end
  
  def add_recurrence_times
    return true if @times.blank?
    @schedule ||= fresh_schedule
    schedule.rtimes.each { |time| schedule.remove_recurrence_time time }
    schedule.add_recurrence_time start_datetime
    @times.each { |time| schedule.add_recurrence_time time } if @times.present?
  end
  
  #def add_recurrence_rules
  #  if @rules.present?
  #    @schedule = fresh_schedule if new_record?
  #    clear_rules!
  #    @rules.each do |rule_params|
  #      rule_params.event = self
  #      rule = Event::RecurrenceRule.new rule_params
  #      iced_rule = rule.to_ice_cube
  #      if iced_rule.present?
  #        schedule.add_recurrence_rule iced_rule
  #      end
  #    end
  #  end
  #end

  def update_rule_expirations!
    @schedule.start_time = start_datetime
    @schedule.end_time = expires_on.to_time if expires_on.present?
    @schedule.duration = duration
    rule.until(expires_on.to_time) if rule.present? and expires_on.present?
  end

end