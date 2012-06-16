module Event::IcalFeed
  extend ActiveSupport::Concern
  included do
    
    def self.new_from_feed(event, feed)
      return if event.dtstart.to_time < Time.now or event.dtstart.to_time > 1.month.from_now
      user = feed.user
      unless user.items.where(type: 'Event', title: event.summary, start_datetime: event.dtstart.to_time).present?
        e = Event.new
        e.title = event.summary
        e.description = event.description.present? ? event.description : event.summary
        e.start_datetime = event.dtstart.to_time
        e.end_datetime = event.dtend.to_time
        e.location = event.location.present? ? event.location : "Location not given"
        e.user = user
        e.tag_list = feed.tag_list
        e.geo_tag_list= feed.geo_tag_list
        e.save!
      end

    end
    
  end
end