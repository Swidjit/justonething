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
end
