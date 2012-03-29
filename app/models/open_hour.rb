class OpenHour < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user_id
  validates_inclusion_of :day_of_week, :in => Date::DAYNAMES

  attr_accessible :day_of_week, :open_time, :close_time

end
