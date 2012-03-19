require 'spec_helper'

describe ItemDecorator do
  before do
    c = ApplicationController.new
    c.request = ActionDispatch::TestRequest.new
    c.set_current_view_context
  end

  it "should linkify hashtags" do
    item = ItemDecorator.decorate Factory.build(:item, :description => "test #tags in descriptions")
    item.stub :all_feeds_path => '/feeds/all/tags'
    item.description.should == "test <a href=\"/feeds/all/tags\">#tags</a> in descriptions"
  end
end
