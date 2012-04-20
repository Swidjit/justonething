require 'spec_helper'

describe FeedsController do

  before(:each) do
    @user = Factory(:user)
  end

  describe "GET all" do
    it 'should only load tagged item' do
      item = Factory(:thought, :user => @user, :tag_list => 'icecream')
      get :index, :type => 'all', :tag_name => 'icecream'
      assigns(:feed_items).should == [item]
      get :index, :type => 'all', :tag_name => 'elephant'
      assigns(:feed_items).should == []
    end
  end

  describe 'GET specific item type' do
    it 'should only load items of the correct type' do
      thought = Factory(:thought, :user => @user)
      want_it = Factory(:want_it, :user => @user)
      get :index, :type => 'thoughts'
      assigns(:feed_items).should == [thought]
      get :index, :type => 'want_its'
      assigns(:feed_items).should == [want_it]
    end
  end

  describe 'GET recommendations' do
    it 'should load only items with recommendations' do
      rec = Factory(:recommendation)
      rec2 = Factory(:recommendation)
      rec3 = Factory(:recommendation, :item => rec2.item)
      get :recommendations
      assigns(:feed_items).should == [rec2.item, rec.item]
    end
  end

  describe "GET nearby" do
    before(:each) do
      sign_in @user
    end
    it 'should be success' do
      get :nearby
      response.should be_success
    end
  end

  describe "GET search" do

    before(:each) do
      other_item = Factory(:thought, :user => @user, :tag_list => 'icecream')
    end

    it "should load items with search term in title" do
      find_me = Factory(:want_it, :user => @user, :title => "Searchable item")
      get :search, {:q => 'Searchable'}
      assigns(:feed_items).should == [find_me]
    end

    it "should load items with search term in description" do
      find_me = Factory(:want_it, :user => @user, :description => "Searchable item")
      get :search, {:q => 'searchable'}
      assigns(:feed_items).should == [find_me]
    end

    it "should load items with search term as tag" do
      find_me = Factory(:thought, :user => @user, :tag_list => 'searchable')
      get :search, {:q => 'searchable'}
      assigns(:feed_items).should == [find_me]
    end

    it "should load items with search term as tag and in title or description" do
      find_me = Factory(:thought, :user => @user, :tag_list => 'searchable')
      find_me_too = Factory(:want_it, :user => @user, :description => "Searchable item")
      get :search, {:q => 'searchable'}
      assigns(:feed_items).should == [find_me_too, find_me]
    end

    it "should still search with logged in users" do
      find_me = Factory(:thought, :user => @user, :tag_list => 'searchable')
      sign_in @user
      get :search, {:q => 'searchable'}
      assigns(:feed_items).should == [find_me]
    end

    it "should only find elements in the correct category when chosen" do
      find_me = Factory(:thought, :user => @user, :tag_list => 'searchable')
      dont_find_me = Factory(:want_it, :user => @user, :description => "Searchable item")
      get :search, {:q => 'searchable', type: 'thoughts'}
      assigns(:feed_items).should == [find_me]
    end
  end

  describe 'scoped to city' do
    it 'should only find items for the city' do
      new_city = Factory(:city)
      in_first_city = Factory(:want_it)
      in_new_city = Factory(:have_it)
      in_new_city.item_visibility_rules.create({:visibility_id => new_city.id, :visibility_type => 'City'})
      get :index, :type => 'all', :city_url_name => new_city.url_name
      assigns(:feed_items).should == [in_new_city]
    end
  end
end
