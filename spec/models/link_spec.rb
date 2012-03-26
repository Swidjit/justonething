require 'spec_helper'

describe Link do
  describe "supports reading and writing:" do
    it "a link" do
      subject.link = 'http://example.com'
      subject.link.should == 'http://example.com'
    end

    it "should not allow offers" do
      subject.allows_offers?.should be_false
    end
  end

  before(:all) { @item_class = Link }
  it_should_behave_like 'an item'
end
