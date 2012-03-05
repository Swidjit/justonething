require 'spec_helper'

describe CommunityInvitationsController do
  describe 'Sending invites' do
    it 'should be successful with valid data' do
      inviter = Factory(:user)
      invitee = Factory(:user)
      community = Factory(:community)
      inviter.communities << community
      sign_in inviter
      post :create, :community_id => community.id, :community_invitation => {:invitee_id => invitee.id}
      flash[:notice].index('success').should be_present
    end

    it 'should fail if the inviter does not belong to community' do
      inviter = Factory(:user)
      invitee = Factory(:user)
      community = Factory(:community)
      sign_in inviter
      post :create, :community_id => community.id, :community_invitation => {:invitee_id => invitee.id}
      flash[:notice].index('fail').should be_present
    end
  end

  describe 'Responding to invites' do
    it 'should properly accept' do
      invitation = Factory(:community_invitation)
      sign_in invitation.invitee
      post :accept, :community_invitation_id => invitation.id
      response.should be_redirect

      invitation.reload
      invitation.status.should == 'A'

      invitation.invitee.communities.should include?(invitation.community)
    end

    it 'should properly decline' do
      invitation = Factory(:community_invitation)
      sign_in invitation.invitee
      post :decline, :community_invitation_id => invitation.id
      response.should be_redirect

      invitation.reload
      invitation.status.should == 'D'
    end
  end
end
