class CommunityInvitationsController < ApplicationController

  respond_to :html

  load_and_authorize_resource :only => [:accept,:decline]

  def create
    @community_invitation = CommunityInvitation.new(params[:community_invitation])
    @community_invitation.inviter = current_user
    @community_invitation.community_id = params[:community_id]
    if @community_invitation.save
      flash[:notice] = 'Invitation successfully sent'
    else
      flash[:notice] = 'Invitation failed to send'
    end
    redirect_to community_path(params[:community_id])
  end

  def accept
    @community_invitation.accept!
    redirect_to community_path(@community_invitation.community)
  end

  def decline
    @community_invitation.decline!
    redirect_to community_path(@community_invitation.community)
  end

end
