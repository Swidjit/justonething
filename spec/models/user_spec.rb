require 'spec_helper'

describe User do
  describe 'supports reading and writing of' do
    it 'an about' do
      subject.about = "I'm silly!"
      subject.about.should == "I'm silly!"
    end
    it 'websites' do
      subject.websites = "qwantz.com xkcd.com"
      subject.websites.should == "qwantz.com xkcd.com"
    end
    it 'an address' do
      subject.address = "1234 Lunar St, Moon"
      subject.address.should == "1234 Lunar St, Moon"
    end
    it 'a phone number' do
      subject.phone = "555-481-7985"
      subject.phone.should == "555-481-7985"
    end
    it 'a zipcode' do
      subject.zipcode = '12345'
      subject.zipcode.should == '12345'
    end
  end

  describe 'a delegate' do
    it 'can be destroyed' do
      user = Factory(:delegate).delegatee
      user.destroy
      user.should_not be_persisted
    end
  end

  describe "Display Name" do
    it "can be changed once" do
      u1 = Factory(:user, :display_name => 'JohnDoe')
      u1.display_name.should == "JohnDoe"
      u1.display_name = "lolsasaur"
      u1.save
      u1.reload
      u1.display_name.should == "JohnDoe"
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

    it "cannot contain spaces" do
      Factory.build(:user, :display_name => 'SP ACE').should_not be_valid
    end
  end
end
