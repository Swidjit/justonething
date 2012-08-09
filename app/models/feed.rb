class Feed < ActiveRecord::Base
  
  attr_accessor :_process
  
  include TagConversion
  
  belongs_to :user
  has_many :events, dependent: :destroy
  has_and_belongs_to_many :tags, :uniq => true, :conditions => "tags.type IS NULL"
  has_and_belongs_to_many :geo_tags, :join_table => :feeds_tags, :association_foreign_key => :tag_id, :uniq => true, :conditions => "tags.type = 'GeoTag'"
  
  validates_presence_of :name, :url, :user
  validate :validate_ical, :if => :url_changed?

  attr_accessible :name, :url, :tag_list, :geo_tag_list, :_destroy, :_process, as: :default
  
  after_initialize :set_defaults
  after_create :process!
  after_update :process_conditionally
  
  # This started off like Item model's set_defaults. If you're using nested attributes, you also have to
  # say the attribute will change and use or= otherwise it blanks out the tags.
  def set_defaults
    attribute_will_change!(:tag_list)
    attribute_will_change!(:geo_tag_list)
    self.tag_list     ||= self.tags.collect(&:name).join(',')
    self.geo_tag_list ||= self.geo_tags.collect(&:name).join(',')
  end
  
  def _process=(value)
    @process_on_save = value == "1"
  end
  
  def process_conditionally
    if @process_on_save 
      @process_on_save = nil
      process!
    else
      true
    end
  end
  
  def process!
    cals = load_url
    return true unless cals
    cal = cals.first

    cal.events.each do |event|
      Event.new_from_feed event, self
    end
    
    update_column :last_read_at, Time.now
    
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
      uri = URI url
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      Icalendar.parse response.body
      # RiCal.parse_string response.body
    rescue Exception => exception
      ExceptionNotifier::Notifier.background_exception_notification(exception, {}).deliver
      false
    end    
  end
  
  def validate_ical
    self.errors[:url] << "is invalid" unless load_url.present?
  end
  
end
