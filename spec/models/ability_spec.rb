require 'spec_helper'

describe Ability do
  describe "an admin" do
    before(:each) { @ability = Ability.new(Factory(:user, :is_admin => true)) }

    it "can manage an item" do
      @ability.can?(:manage, Item).should == true
    end
  end
end
