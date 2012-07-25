class EventDecorator < ItemDecorator
  decorates :event

  def cost
    event.cost || 'Free'
  end

  def start_datetime(format = 'datetime')
    if params[:event].present? && params[:event]["start_#{format}".to_sym].present?
      params[:event]["start_#{format}".to_sym]
    elsif event.start_datetime.present?
      event.start_datetime.strftime(send("#{format}_format"))
    end
  end
  
  def date
    event.start_datetime.to_date
  end

  def end_datetime(format = 'datetime')
    if params[:event].present? && params[:event]["end_#{format}".to_sym].present?
      params[:event]["end_#{format}".to_sym]
    elsif event.end_datetime.present?
      event.end_datetime.strftime(send("#{format}_format"))
    end
  end
  
  def next_occurrence(format = 'datetime')
    event.is_recurring? ? "#{event.rule.to_s} @ #{start_datetime('time')}" : start_datetime
    #event.next_occurrence.strftime(send("#{format}_format"))
  end

  def weekday_options
    [
      ["Monday", 1],
      ["Tuesday", 2],
      ["Wednesday", 3],
      ["Thursday", 4],
      ["Friday", 5],
      ["Saturday", 6],
      ["Sunday", 7]
    ]
  end
  
  def week_of_month_options
    [
      ["1st", 1],
      ["2nd", 2],
      ["3rd", 3],
      ["4th", 4],
      ["Last", -1]
    ]
  end
  
  def date_of_month_options
    (1..31).map { |n| [n.ordinalize, n] }
  end
  
  def description
    html = super
    if event.is_recurring?
      date = @event_date || Time.now
      upcoming_events = event.next_occurrences 6, date
      if upcoming_events.present?
        html << content_tag(:h4, 'Upcoming dates for this event')
        collection_arr = upcoming_events.map {|date| content_tag :li, date.to_s(:short) }
        html << content_tag(:ul, collection_arr.join('').html_safe)
      end
    end
    html
  end

  private
  # TODO: Move this to an initializer and use datetime.to_s(:format_defined_in_initializer)
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