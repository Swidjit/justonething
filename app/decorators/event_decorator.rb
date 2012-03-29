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

  def end_datetime(format = 'datetime')
    if params[:event].present? && params[:event]["end_#{format}".to_sym].present?
      params[:event]["end_#{format}".to_sym]
    elsif event.end_datetime.present?
      event.end_datetime.strftime(send("#{format}_format"))
    end
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