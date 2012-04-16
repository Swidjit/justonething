require 'spec_helper'

describe Collection do
  before(:all) { @item_class = Collection }

  it "should not allow offers" do
    subject.allows_offers?.should be_false
  end

  it { should have_many :items }

  it_should_behave_like 'an item'
end
