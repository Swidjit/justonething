module Event::IcalFeed
  extend ActiveSupport::Concern
  included do
    
    def self.new_from_feed(event, feed)
      #return if event.recurrence_rules.blank? and event.dtstart.to_time < Time.now or event.dtstart.to_time > 1.month.from_now
      user = feed.user
      starts_at = event.dtstart
      ends_at = event.dtend
      e = user.items.where(type: 'Event', title: event.summary, start_datetime: starts_at).includes([:cities, :item_visibility_rules]).first
      unless e.present?
        e = Event.new
        e.imported = true
      end
      e.feed = feed
      e.start_datetime = starts_at
      e.end_datetime = ends_at
      if event.recurrence_rules.present?
        e.clear_rules! if e.rule.present?
        e.expires_on = nil
        event.recurrence_rules.each do |rule|
          e.schedule.add_recurrence_rule IceCube::Rule.from_ical(rule.orig_value.sub(/;WKST=\w\w/,''))            
        end
        event.exception_dates.each do |time|
          e.schedule.add_exception_time time.to_time
        end
      end
      next_time = e.next_occurrence
      return if next_time.blank? or next_time < Time.now or next_time > 1.month.from_now
      e.title = event.summary
      e.description = event.description.present? ? event.description : event.summary
      if e.location.blank? or e.location == "Location not given"
        if event.location.present?
          e.location = event.location
        else
          e.location = feed.location || "Location not given"
        end
      end
      e.user = user
      e.tag_list = feed.tag_list
      e.geo_tag_list= feed.geo_tag_list
      e.save 
      if e.persisted? and e.cities.blank? and user.cities.any?
        city = user.cities.first
        e.item_visibility_rules.find_or_create_by_visibility_id_and_visibility_type(city.id, 'City')
      end      
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