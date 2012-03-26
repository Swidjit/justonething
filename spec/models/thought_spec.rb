require 'spec_helper'

describe Thought do
  before(:all) { @item_class = Thought }

  it "should not allow offers" do
    subject.allows_offers?.should be_false
  end

  it_should_behave_like 'an item'
end
