require 'spec_helper'

describe Comment do
  describe "supports reading and writing of" do
    it "a text" do
      subject.text = 'This is off the wall!'
      subject.text.should == 'This is off the wall!'
    end
  end

  it { should belong_to :item }
  it { should belong_to :user }
end
