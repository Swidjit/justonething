class Item < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user_id, :user, :title, :description, :expires_in

  attr_accessor :expires_in

  before_save :convert_expires_in_to_expires_on

  private
  def convert_expires_in_to_expires_on
    if expires_in.present? && expires_in.to_i > 0
      self.expires_on = expires_in.to_i.days.from_now.to_date
    end
  end

end