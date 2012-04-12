require 'spec_helper'

describe FeedsController do

  before(:each) do
    @user = Factory(:user)
  end

  describe "GET all" do
    it 'should only load tagged item' do
      item = Factory(:thought, :user => @user, :tag_list => 'icecream')
      get :all, :tag_name => 'icecream'
      assigns(:feed_items).should == [item]
      get :all, :tag_name => 'elephant'
      assigns(:feed_items).should == []
    end
  end

  describe 'GET specific item type' do
    it 'should only load items of the correct type' do
      thought = Factory(:thought, :user => @user)
      want_it = Factory(:want_it, :user => @user)
      get :thoughts
      assigns(:feed_items).should == [thought]
      get :want_its
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

  end
end
