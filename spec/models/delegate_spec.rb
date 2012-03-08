require 'spec_helper'

describe Delegate do
  context "creating a delegate" do
    before(:each) do
      @delegator = Factory(:user)
      @delegatee = Factory(:user)
      @delegation = Factory(:delegate, :delegator => @delegator, :delegatee => @delegatee)
    end

    it "should add the delegatee to the delegator" do
      @delegator.delegatees.first.should == @delegatee
    end

    it "should add the delegator to the delegatee" do
      @delegatee.delegators.first.should == @delegator
    end
  end
end
