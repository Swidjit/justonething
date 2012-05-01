class Event < Item
  attr_accessible :cost, :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time
  validates_presence_of :location, :start_datetime, :end_datetime, :start_date, :start_time,
    :end_date, :end_time
  attr_accessor :start_time, :start_date, :end_time, :end_date

  has_many :rsvps, :dependent => :destroy, :foreign_key => :item_id

  scope :order_by_start_datetime, :order => "start_datetime ASC"

  validate :start_datetime_in_future

  # week is zero-indexed starting with the current day as the first day of the first week
  scope :for_week, lambda { |week| {
    :conditions => ["#{Event.table_name}.start_datetime >= ? AND #{Event.table_name}.start_datetime <= ?",
                    (week * 7).days.from_now.beginning_of_day, ((week + 1) * 7).days.from_now.end_of_day]
  } }

  scope :for_date, lambda { |date| {
    :conditions => ["#{Event.table_name}.start_datetime >= ? AND #{Event.table_name}.start_datetime <= ?", date.beginning_of_day, date.end_of_day]
  } }

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
      Time.strptime("#{datetime_value.strip} #{time_zone}",'%m/%d/%Y %l:%M %P %Z')
    else
      datetime_value
    end
  end

private

  def start_datetime_in_future
    errors.add(:start_date, "must be not have already passed") if start_datetime.present? && start_datetime < DateTime.now
  end
end
