class Event < Item
  
  include Recurrences
  include Occurrences
  include IcalFeed
  include Reminders
  
  attr_accessible :cost, :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time, :rule, :weekly_day, :monthly_week, :monthly_day, :monthly_date, :times

  validates_presence_of :location, :start_datetime, :end_datetime
  validates_presence_of :start_date, :start_time, :end_date, :end_time, if: :processing_through_ui?
  validate :start_datetime_in_future, on: :create
  validate :event_ends_after_it_starts
  
  attr_accessor :start_time, :start_date, :end_time, :end_date

  has_many :rsvps, :dependent => :destroy, :foreign_key => :item_id
  has_many :rsvp_users, :through => :rsvps, :source => :user
  
  scope :order_by_start_datetime, :order => "start_datetime ASC"

  scope :upcoming, lambda {
    { :conditions => ["#{Event.table_name}.start_datetime >= ?", DateTime.now.beginning_of_day] }
  }

  scope :between, lambda {|from, to| 
    where("(#{Event.table_name}.start_datetime >= :from AND #{Event.table_name}.end_datetime <= :to) OR " + 
          "((#{Event.table_name}.expires_on IS NULL OR #{Event.table_name}.expires_on >= :from) AND " + 
          "#{Event.table_name}.rules IS NOT NULL AND #{Event.table_name}.rules NOT LIKE '%rrules:[]%')", 
          { from: from, to: to })
  }
  
  scope :owned_or_bookmarked_by_or_rsvp_to, lambda { |user| {
    :select => "DISTINCT #{Item.table_name}.*",
    :joins => "LEFT JOIN #{Bookmark.table_name} ON #{Bookmark.table_name}.item_id = #{Item.table_name}.id " +
        "LEFT JOIN #{Rsvp.table_name} ON #{Rsvp.table_name}.item_id = #{Item.table_name}.id",
    :conditions => ["#{Item.table_name}.user_id = ? OR
      (#{Rsvp.table_name}.user_id = ? AND #{Rsvp.table_name}.id IS NOT NULL) OR
      (#{Bookmark.table_name}.user_id = ? AND #{Bookmark.table_name}.id IS NOT NULL)", user.id, user.id, user.id]
  } }

  def self.datetimepicker_to_datetime(datetime_value, time_zone)
    if datetime_value.is_a?(String) && datetime_value.present?
      Time.strptime("#{datetime_value.strip} #{time_zone.tzinfo.current_period.abbreviation.to_s}",'%m/%d/%Y %l:%M %P %Z')
    else
      datetime_value
    end
  end
    
  def duration
    @duration ||= end_datetime ? (end_datetime - start_datetime) : 3600    
  end
  
  
  private

  def start_datetime_in_future
    errors.add(:start_date, "must not have already passed") if rule.blank? && start_datetime.present? && start_datetime < DateTime.now
  end
  
  def event_ends_after_it_starts
    errors.add(:end_date, "must be later than start date") if start_datetime.present? && end_datetime.present? && end_datetime < start_datetime
  end
    
end
