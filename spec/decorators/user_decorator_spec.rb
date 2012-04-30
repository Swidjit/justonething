require 'spec_helper'

describe UserDecorator do
  it "#name" do
    user = Factory(:user, :first_name => 'First', :last_name => 'Last')
    UserDecorator.new(user).name.should == 'First Last'
  end
end
