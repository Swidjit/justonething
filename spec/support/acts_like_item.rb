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
      two_days_from_now = 2.days.from_now
      subject.expires_on = two_days_from_now
      subject.expires_on.to_s.should == two_days_from_now.to_s
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

  it 'should convert geo_tag_list to geo_tags' do
    subject = Factory.build(:want_it)
    subject.geo_tag_list = 'big, hairy, orange'
    subject.save
    subject.geo_tags.count.should == 3
    GeoTag.all.count.should == 3
  end

  it 'should find hashtags in description and add them to tags' do
    subject = Factory.build(:want_it)
    subject.description = "This is for #you my #dear"
    subject.save
    subject.tags.collect(&:name).sort.should == %w( dear you )
  end

  it 'should be searchable by tags' do
    subject = Factory.build(:want_it)
    subject.tag_list = "italian-stallion"
    subject.save
    Item.search('italian-stallion').should == [subject]
  end

  it 'should be searchable by title' do
    subject = Factory.build(:want_it)
    subject.title = "Rocky"
    subject.save
    Item.search('rocky').should == [subject]
  end

  it 'should be searchable by description' do
    subject = Factory.build(:want_it)
    subject.description = "heavyweight champion of the world"
    subject.save
    Item.search('champion').should == [subject]
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

  it "#has_offer_from?" do
    offer = Factory(:offer)
    offer.item.has_offer_from?(offer.user).should be_true

    offer.item.has_offer_from?(Factory(:user)).should be_false
  end

  describe "#having_tag_with_tag" do
    before(:each) { @item = Factory(:item, :tag_list => 'test1') }

    it "item should appear with test1" do
      Item.having_tag_with_name('test1').should include @item
    end

    it "item should not appear with test2" do
      Item.having_tag_with_name('test2').should_not include @item
    end
  end

  describe "flagging" do
    before(:each) do
      @user = Factory(:user)
      @item = Factory(@item_class.to_s.underscore.to_sym)
      @item.flag!(@user)
    end

    it "can be flagged" do
      ItemFlag.count.should == 1
    end

    it "can be flagged only once" do
      @item.flag!(@user)
      ItemFlag.count.should == 1
    end

    it "can determine if a user has flagged it" do
      @item.flagged_by_user?(@user).should be_true
    end

    it "can be gathered with a named scope" do
      not_flagged = Factory(:item)
      flagged_items = Item.flagged.all

      flagged_items.should include @item
      flagged_items.should_not include not_flagged
    end
  end

  describe "disabling" do
    before(:each) { @item = Factory(@item_class.to_s.underscore.to_sym) }

    it "can be disabled" do
      @item.disable!
      @item.should be_disabled
    end

    it "will not appear in listings of items" do
      Item.all.should include @item
      @item.disable!
      Item.all.should_not include @item
    end
  end

  it_behaves_like "a referencing object", { :factory => :item, :fields => %w( description title ) }
end
