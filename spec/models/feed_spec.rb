require 'spec_helper'

describe Feed do
  it { should belong_to :user }
  it { should have_and_belong_to_many :tags }
  it { should have_and_belong_to_many :geo_tags }
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :url }
  it { should validate_presence_of :user }
  
  it "should process the feed" do
    VCR.use_cassette('ical_feed', erb: true, allow_playback_repeats: true) do
      feed = Factory :feed
      feed.process!
      feed.user.items.count.should > 1
    end
  end
  
  it "should save tags and geotags" do
    VCR.use_cassette('ical_feed', erb: true, allow_playback_repeats: true) do
      feed = Factory :feed
      feed.tag_list = "gardens,muppets"
      feed.geo_tag_list = "ithaca,dryden"
      feed.save
      feed.reload
      feed.tags.count.should == 2
      feed.geo_tags.count.should == 2
    end
  end
  
end
