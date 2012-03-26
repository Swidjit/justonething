require 'spec_helper'

describe WantIt do
  before(:all) { @item_class = WantIt }

  it "should allow offers" do
    subject.allows_offers?.should be_true
  end

  it_should_behave_like 'an item'
end
