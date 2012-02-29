require 'spec_helper'

describe User do
  describe "URL" do
    it "has proper default" do
      u1 = Factory(:user, :display_name => 'John Doe')
      u1.url.should == 'johndoe'
      u2 = Factory(:user, :display_name => 'John Doe')
      u2.url.should == 'johndoe1'
    end

    it "can be changed once" do
      u1 = Factory(:user, :display_name => 'John Doe')
      u1.user_set_url.should == false
      u1.url = "itsamemario"
      u1.save
      u1.reload
      u1.user_set_url.should == true
      u1.url.should == "itsamemario"
      u1.url = "lolsasaur"
      u1.save
      u1.reload
      u1.url.should == "itsamemario"
    end
  end
end
