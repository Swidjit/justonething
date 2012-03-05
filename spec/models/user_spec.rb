require 'spec_helper'

describe User do
  describe "Display Name" do
    it "can be changed once" do
      u1 = Factory(:user, :display_name => 'JohnDoe', :user_set_display_name => false)
      u1.display_name = "itsamemario"
      u1.save
      u1.reload
      u1.user_set_display_name.should == true
      u1.display_name.should == "itsamemario"
      u1.display_name = "lolsasaur"
      u1.save
      u1.reload
      u1.display_name.should == "itsamemario"
    end
  end
end
