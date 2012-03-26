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

    it 'a has expiration flag' do
      subject.has_expiration = 1
      subject.has_expiration.should == 1
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

    it 'an active flag' do
      subject.active = false
      subject.active.should == false
    end

    it 'a public flag' do
      subject.public = false
      subject.public.should == false
    end
  end

  it { should belong_to :user }

  it { should belong_to :posted_by_user }

  it { should have_and_belong_to_many :tags }

  it 'should convert tag_list to tags' do
    subject = Factory.build(:want_it)
    subject.tag_list = 'big, hairy, orange'
    subject.save
    subject.tags.count.should == 3
  end

  it 'should find hashtags in description and add them to tags' do
    subject = Factory.build(:want_it)
    subject.description = "This is for #you my #dear"
    subject.save
    subject.tags.collect(&:name).sort.should == %w( dear you )
  end

  it 'should not be valid if posted_by_user is not a delegatee of user' do
    item = Factory.build(@item_class.to_s.underscore.to_sym, :posted_by_user => Factory(:user))
    item.should be_invalid
    item.errors.messages.should have_key(:user)
  end

  it 'should keep a counter cache of recommendations' do
    item = Factory(:item)
    item.recommendations_count.should == 0
    rec = Factory(:recommendation, :item => item)
    item.reload
    item.recommendations_count.should == 1
  end

  it 'should update user familiarity on save' do
    item = Factory(:item)
    user = Factory(:user)
    item.description = "I know @#{user.display_name} too!"
    item.save
    uf = UserFamiliarity.find_by_user_id_and_familiar_id(item.user.id,user.id)
    uf.familiarness.should > 0
  end

  it "#has_offer_from?" do
    offer = Factory(:offer)
    offer.item.has_offer_from?(offer.user).should be_true

    offer.item.has_offer_from?(Factory(:user)).should be_false
  end
end
