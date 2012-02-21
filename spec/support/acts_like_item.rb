require 'spec_helper'

shared_examples "an item" do
  describe "supports reading and writing:" do
    it "a description" do
      subject.description = 'New description'
      subject.description.should == 'New description'
    end

    it 'a title' do
      subject.title = 'New title'
      subject.title.should == 'New title'
    end

    it 'the amount of time it should last' do
      subject.expires_in = '1 day'
      subject.expires_in.should == '1 day'
    end

    it 'an expiration date' do
      subject.expires_on = 2.days.from_now
      # Comparing dates directly doesn't work for some reason so we cast them to a string
      subject.expires_on.to_s.should == 2.days.from_now.to_s
    end

    it 'a tag list' do
      subject.tag_list = 'big, hairy, orange'
      subject.tag_list.should == 'big, hairy, orange'
    end
  end

  it { should belong_to :user }

  it { should have_and_belong_to_many :tags }

  it 'should convert expires in to an expiration date' do
    subject = Factory.build(:want_it)
    subject.expires_in = '5'
    subject.save
    subject.expires_on.should == 5.days.from_now.to_date
  end

  it 'should convert tag_list to tags' do
    subject = Factory.build(:want_it)
    subject.tag_list = 'big, hairy, orange'
    subject.save
    subject.tags.count.should == 3
  end
end