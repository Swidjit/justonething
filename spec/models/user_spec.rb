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

    it "can be searched on" do
      Factory(:user, :display_name => "bob")
      Factory(:user, :display_name => "bob1")
      Factory(:user, :display_name => "1bob1")
      Factory(:user, :display_name => "sam")

      User.lower_display_name_like('bob').all.count.should == 3
      User.lower_display_name_like('sam').all.count.should == 1
      User.lower_display_name_like('nil').all.count.should == 0
    end
  end
end
