require 'spec_helper'

describe CollectionsController do

  before(:each) do
    request.env["HTTP_REFERER"] = '/'
  end

  it "should successfully add an item" do
    collection = Factory(:collection)
    item = Factory(:want_it)
    user = collection.user
    sign_in user

    post :add_item, :id => collection.id, :item_id => item.id
    response.should be_redirect

    collection.reload
    collection.items.should == [item]
  end

  it "should fail to add an item for other users" do
    collection = Factory(:collection)
    item = Factory(:want_it)
    user = item.user
    sign_in user

    post :add_item, :id => collection.id, :item_id => item.id
    response.should be_redirect

    collection.reload
    collection.items.count.should == 0
  end

  it_should_behave_like 'an item controller'
end
