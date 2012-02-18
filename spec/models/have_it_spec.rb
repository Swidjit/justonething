require 'spec_helper'

describe HaveIt do
  describe "supports reading and writing:" do
    it "a cost" do
      subject.cost = '$40'
      subject.cost.should == '$40'
    end

    it "a condition" do
      subject.condition = 'Fair'
      subject.condition.should == 'Fair'
    end
  end
end
