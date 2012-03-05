require 'spec_helper'

describe CommunityInvitation do
  describe "supports reading and writing:" do

    it 'a status' do
      subject.status = 'A'
      subject.status.should == 'A'
    end

  end

  it { should belong_to :invitee }

  it { should belong_to :inviter }

  it { should belong_to :community }

  it 'should validate that the inviter belongs ot the community' do
    subject.invitee = Factory(:user)
    subject.inviter = Factory(:user)
    subject.community = Factory(:community)
    subject.valid?.should be_false

    subject.inviter.communities << subject.community
    subject.valid?.should be_true
  end
end
