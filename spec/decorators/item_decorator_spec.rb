require 'spec_helper'

describe ItemDecorator do
  before do
    c = ApplicationController.new
    c.request = ActionDispatch::TestRequest.new
    c.set_current_view_context
  end

  it "should linkify hashtags" do
    item = ItemDecorator.decorate Factory.build(:item, :description => "test #tags in descriptions")
    item.h.stub :main_feeds_path => '/feeds/all/tags'
    item.description.should == "<p>test <a href=\"/feeds/all/tags\" class=\"no-text-dec\">#tags</a> in descriptions</p>"
  end
end
