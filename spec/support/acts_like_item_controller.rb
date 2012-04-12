require 'spec_helper'

shared_examples "an item controller" do
  render_views

  before(:each) do
    @object_sym = @controller.controller_name.singularize.to_sym
    @object_attributes = Factory.attributes_for(@object_sym, :expires_on => 2.days.from_now.strftime('%m/%d/%Y'))
    @object_attributes.delete(:user)
  end

  describe "the new item form" do
    it "should not show the user_id select if the user is not a delagatee" do
      sign_in Factory(:user)
      get :new
      response.body.should_not =~ /Posting as/
    end

    it "should show the user_id select if the user is a delegatee" do
      delegatee = Factory(:user)
      Factory(:delegate, :delegatee => delegatee)
      sign_in delegatee
      get :new
      response.body.should =~ /Posting as/
    end
  end

  describe "adding a new item" do
    it "should not allow a user to set the user_id to not one of their delegates" do
      @object_attributes[:user_id] = Factory(:user).id

      sign_in Factory(:user)
      post :create, @object_sym => @object_attributes

      Item.count.should == 0
    end

    it "should allow a user to set the user_id to one of their delegates" do
      delegation = Factory(:delegate)
      @object_attributes[:user_id] = delegation.delegator.id

      sign_in delegation.delegatee
      post :create, @object_sym => @object_attributes

      Item.count.should == 1
      Item.first.user.should == delegation.delegator
      Item.first.posted_by_user.should == delegation.delegatee
    end
  end

  describe "Duplicate" do
    it 'should render new form prepopulated with specified items info' do
      user = Factory(:user)
      item = ItemDecorator.decorate Factory(@object_sym, :expires_on => 2.days.from_now, :tag_list => 'icecream, funstuff')
      sign_in user
      get :duplicate, :id => item.id
      response.should render_template("new")
      dup_item = assigns(:item) # This will be decorated
      dup_item.title.should == item.title
      dup_item.description.should == item.description
      dup_item.tag_list.split(',').count.should == item.tags.count
      dup_item.expires_on.should == 10.days.from_now.strftime('%m/%d/%Y')
      dup_item.id.should_not == item.id
    end
  end

  describe "Visibility Rules" do
    it 'should remove the visibility rule' do
      user = Factory(:user)
      item = Factory(@object_sym)
      list = Factory(:list, :user => user)
      item.lists << list
      item.list_ids.count.should == 1
      sign_in user
      delete :remove_visibility_rule, :id => item.id, :visibility_type => 'list', :visibility_id => list.id, :format => :json
      response.should be_success
      item.list_ids.count.should == 0
    end

    it 'should add the visibility rule' do
      user = Factory(:user)
      item = Factory(@object_sym)
      list = Factory(:list, :user => user)
      item.list_ids.count.should == 0
      sign_in user
      post :add_visibility_rule, :id => item.id, :visibility_type => 'list', :visibility_id => list.id, :format => :json
      response.should be_success
      item.list_ids.count.should == 1
    end
  end

  describe "flagging" do
    it "can be performed by a logged in user" do
      request.env["HTTP_REFERER"] = "/"
      item = Factory(@object_sym)
      user = Factory(:user)
      sign_in user
      put :flag, :id => item.id
      item.flagged_by_user?(user).should be_true
    end
  end
end
