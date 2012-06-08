require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  describe "GET show" do
    render_views

    before(:each) { @target_user = Factory(:user) }

    it "should be visible by guest" do
      get :show, :display_name => @target_user.display_name
      response.should be_success
    end

    context "with render views" do
      context "logged in user view own profile" do
        before(:each) do
          @user = Factory(:user)
          sign_in @user
          get :show, :display_name => @user.display_name
        end

        it "should not display add delegat link" do
          response.body.should_not =~ /add as delegate/
        end
      end

      context "logged in user viewing other's profile" do
        before(:each) do
          sign_in Factory(:user)
          get :show, :display_name => @target_user.display_name
        end

        it "should be successful" do
          response.should be_success
        end

        it "should display a link to add the user as a delegate" do
          response.body.should =~ /add as delegate/
        end
      end

      it "logged in user viewing their delegate's profile should see remove as delegate link" do
        delegation = Factory(:delegate, :delegatee => @target_user)
        sign_in delegation.delegator
        get :show, :display_name => @target_user.display_name

        response.body.should =~ /remove as delegate/
      end
    end
  end

  describe 'PUT update' do
    render_views

    before(:each) do
      @user = Factory(:user)
      sign_in @user
    end

    it "should display errors when data is invalid" do
      post :update, :id => @user.id, :user => {:zipcode => nil}
      response.body.should =~ /<div class='error'>/
    end

    it "should change the user profile" do
      about = SecureRandom.base64(12)
      put :update, :id => @user.id, :user => {:about => about}
      @user.reload.about.should == about
    end
    
    it "should add a feed to the user profile" do
      params = {
        feeds_attributes: {
          0 => {
            name: "Garden Events", 
            url: "http://www.google.com/calendar/ical/ju6l13rier0b6t6cm8bn7r4fvo%40group.calendar.google.com/public/basic.ics",
            tag_list: "gardens", 
            geo_tag_list: "ithaca"
          }
        }
      }
      VCR.use_cassette('ical_feed', erb: true, allow_playback_repeats: true) do
        put :update, id: @user.id, user: params
        @user.reload.feeds.count.should == 1
        feed = @user.feeds.first
        feed.tag_list.should == 'gardens'
        feed.geo_tag_list.should == 'ithaca'
      end
    end
    
  end

  describe 'GET references' do
    before(:each) { @target_user = Factory(:user) }

    it "should find appropriate items" do
      tagged_desc = "This is at @#{@target_user.display_name}"
      item1 = Factory(:thought, :description => tagged_desc)
      item2 = Factory(:want_it)
      item3 = Factory(:have_it, :active => false, :description => tagged_desc)

      sign_in @target_user
      get :references, :id => @target_user.id
      response.should be_success
      assigns(:feed_items).length.should == 1
    end
  end

  describe 'GET suggestions' do
    before(:each) do
      @user = Factory(:user)
      sign_in @user
    end

    it "should get familiar users if they exist" do
      name = 'friend'
      Factory(:user_familiarity, :user => @user, :familiar => Factory(:user, :display_name => name))

      for i in 0..name.length-1
        get :suggestions, :id => name[0..i], :format => 'json'
        response.should be_success
        response.body.should == { :users => [:friend] }.to_json
      end
    end

    it "should fall back to all users if they exist" do
      name = 'stranger'
      Factory(:user, :display_name => name)

      for i in 0..name.length-1
        get :suggestions, :id => name[0..i], :format => 'json'
        response.should be_success
        response.body.should == { :users => [:stranger] }.to_json
      end
    end

    it "should get nothing if send dummy data" do
      get :suggestions, :id => 'foo_bar_bim_baz', :format => 'json'
      response.should be_success
      response.body.should == { :users => [] }.to_json
    end
  end
end
