module Event::Occurrences

  def next_occurrence(time=nil)
    time = time.present? ? time.to_time : Time.now
    rule.present? ? schedule.next_occurrence(time) : start_datetime
  end

  def occurrences_between(from, to)
    if is_recurring?
      schedule.occurrences_between(from.utc, to.utc).map {|date| to_occurrence(date) }.compact
    else
      (start_datetime >= from and end_datetime <= to) ? [self] : []
    end
  end
    
  # The reason is to create multiple event records with the same id but different start date for recurring records,
  # then freeze them so nobody screws up the master.
  def to_occurrence(date)
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
    time = Time.at adjust_time_for_date(date)
    schedule.add_exception_time time.utc
    save
    Reminder.send_cancellation_notices self, date
  end
    
  def adjust_time_for_date(date)
    add_time = start_datetime.to_i - start_datetime.beginning_of_day.to_i
    Date.parse(date).to_time.to_i + add_time
  end
    
    
end

