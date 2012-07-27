module Event::Occurrences

  def next_occurrence(time=nil)
    time = time.present? ? time.to_time : Time.now
    rule.present? ? schedule.next_occurrence(time) : start_datetime
  end
  
  def next_occurrences(num, time=nil)
    time = time.present? ? time.to_time : Time.now
    rule.present? ? schedule.next_occurrences(num, time) : [start_datetime]
  end
  
  def occurs_on?(date)
    rule.present? ? schedule.occurs_on?(date.to_date) : (start_datetime >= date && end_datetime <= date)
  end

  def occurrences_between(from, to)
    if is_recurring?
      schedule.occurrences_between(from, to).map {|date| to_occurrence(date) }.compact
    else
      (start_datetime >= from and end_datetime <= to) ? [self] : []
    end
  end
    
  # The reason is to create multiple event records with the same id but different start date for recurring records,
  # then freeze them so nobody screws up the master.
  def to_occurrence(date)
    if date.is_a?(Date)
      date = next_occurrence(date)
    end
    event = Event.new
    event.start_datetime = date
    event.end_datetime = date + duration
    event.title = title
    event.description = description
    event.location = location
    event.id = id
    event.user = user
    event.is_recurrence!
    event.set_as_persisted!
    event.freeze
  end
    
  def set_as_persisted!
    @new_record = false
  end
    
  def cancel_occurrence(date)
    times = schedule.occurrences_between Date.parse(date).to_time.beginning_of_day, Date.parse(date).to_time.end_of_day
    times.each do |time|
      schedule.add_exception_time time
    end
    save
    Reminder.send_cancellation_notices self, date
  end
    
    
end

