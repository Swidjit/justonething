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

    it "should not allow duplicate delegates" do
      duplicate = Factory.build(:delegate, :delegator => @delegator, :delegatee => @delegatee)
      duplicate.should_not be_valid
    end
  end

  it "should not allow the delegator to delegate to themselves" do
    both = Factory(:user)
    tautology = Factory.build(:delegate, :delegator => both, :delegatee => both)
    tautology.should_not be_valid
  end

  it "should notify the delegatee after creation" do
    delegation = Factory(:delegate)
    delegation.delegatee.notifications.count.should == 1
  end
end
