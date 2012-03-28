require 'spec_helper'

describe CommunityInvitation do
  describe "supports reading and writing:" do

    it 'a status' do
      subject.status = 'A'
      subject.status.should == 'A'
    end

    it 'a invitee_display_name' do
      subject.invitee_display_name = 'User1'
      subject.invitee_display_name.should == 'User1'
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

  it 'should notify invitee after creation' do
    invite = Factory(:community_invitation)
    invite.invitee.notifications.count.should > 0
  end
end
