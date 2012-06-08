class Feed < ActiveRecord::Base
  
  include TagConversion
  
  belongs_to :user
  has_and_belongs_to_many :tags, :uniq => true, :conditions => "tags.type IS NULL"
  has_and_belongs_to_many :geo_tags, :join_table => :feeds_tags, :association_foreign_key => :tag_id, :uniq => true, :conditions => "tags.type = 'GeoTag'"
  
  validates_presence_of :name, :url, :user
  validate :validate_ical, :if => :url_changed?

  attr_accessible :name, :url, :tag_list, :geo_tag_list, as: :default
  
  after_initialize :set_defaults
  
  # This started off like Item model's set_defaults. If you're using nested attributes, you also have to
  # say the attribute will change and use or= otherwise it blanks out the tags.
  def set_defaults
    attribute_will_change!(:tag_list)
    attribute_will_change!(:geo_tag_list)
    self.tag_list     ||= self.tags.collect(&:name).join(',')
    self.geo_tag_list ||= self.geo_tags.collect(&:name).join(',')
  end
  
  def process!
    cals = load_url
    return unless cals
    cal = cals.first

    cal.events.each do |event|
      Event.new_from_feed event, self
    end
    
    update_attribute :last_read_at, Time.now
    
  end
  
  def self.process!
    find_each {|feed| feed.process! }
  end

  def auto_tag_field
    name
  end
  
  def model
    self
  end
  
  private
  
  def load_url
    begin
      response = Net::HTTP.get_response(URI(url))
      Icalendar.parse response.body
    rescue Exception => e
      false
    end    
  end
  
  def validate_ical
    self.errors[:url] << "is invalid" unless load_url.present?
  end
  
end
