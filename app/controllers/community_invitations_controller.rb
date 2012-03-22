class CommunityInvitationsController < ApplicationController

  respond_to :html

  load_and_authorize_resource :only => [:accept,:decline]
  authorize_resource :only => :create

  def create
    @community_invitation = CommunityInvitation.new(params[:community_invitation])
    @community_invitation.inviter = current_user
    @community_invitation.community_id = params[:id]
    if @community_invitation.save
      flash[:notice] = 'Invitation successfully sent'
    else
      flash[:notice] = "Invitation failed to send" #{@community_invitation.errors.full_messages}"
    end
    redirect_to community_path(params[:id])
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
