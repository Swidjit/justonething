module Event::IcalFeed
  extend ActiveSupport::Concern
  included do
    
    def self.new_from_feed(event, feed)
      #return if event.recurrence_rules.blank? and event.dtstart.to_time < Time.now or event.dtstart.to_time > 1.month.from_now
      user = feed.user
      e = user.items.where(type: 'Event', title: event.summary, start_datetime: event.dtstart.to_time).first
      unless e.present?
        e = Event.new
        e.imported = true
      end
      e.start_datetime = event.dtstart.to_time
      e.end_datetime = event.dtend.to_time
      if event.recurrence_rules.present?
        e.expires_on = nil
        event.recurrence_rules.each do |rule|
          e.schedule.add_recurrence_rule IceCube::Rule.from_ical(rule.orig_value.sub(/;WKST=\w\w/,''))            
        end
        event.exception_dates.each do |time|
          e.schedule.add_exception_time time
        end
      end
      next_time = e.next_occurrence
      puts next_time.inspect
      puts e.start_datetime.inspect
      puts e.rule.to_s
      return if next_time.blank? or next_time < Time.now or next_time > 1.month.from_now
      
      e.title = event.summary
      e.description = event.description.present? ? event.description : event.summary
      e.location = event.location.present? ? event.location : "Location not given"
      e.user = user
      e.tag_list = feed.tag_list
      e.geo_tag_list= feed.geo_tag_list
      e.save
      e

    end
    
    # Convert to iCalendar
    def to_ics(opts={})
      standalone = opts[:standalone]
      calendar = Icalendar::Calendar.new if standalone
      event = Icalendar::Event.new
      event.start = start_datetime.strftime("%Y%m%dT%H%M%S")
      event.end = end_datetime.strftime("%Y%m%dT%H%M%S")
      event.summary = title
      event.description = description
      event.location = location
      event.klass = "PUBLIC"
      event.created = created_at
      event.last_modified = updated_at
      event.uid = event.url = "http://swidjit.com/events/#{to_param}"
      event.add_recurrence_rule(rule.to_ical) if is_recurring?
      if standalone
        calendar.add_event to_ics
        calendar.publish
        calendar.to_ical
      else
        event
      end
    end
    
  end
end