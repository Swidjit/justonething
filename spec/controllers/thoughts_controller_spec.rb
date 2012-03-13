require 'spec_helper'

describe ThoughtsController do
  describe "Duplicate" do
    it 'should render new form prepopulated with specified items info' do
      user = Factory(:user)
      item = ThoughtDecorator.decorate Factory(:thought, :expires_on => 2.days.from_now, :tag_list => 'icecream, funstuff')
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
      item = Factory(:thought)
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
      item = Factory(:thought)
      list = Factory(:list, :user => user)
      item.list_ids.count.should == 0
      sign_in user
      post :add_visibility_rule, :id => item.id, :visibility_type => 'list', :visibility_id => list.id, :format => :json
      response.should be_success
      item.list_ids.count.should == 1
    end
  end

  it_should_behave_like 'an item controller'
end
