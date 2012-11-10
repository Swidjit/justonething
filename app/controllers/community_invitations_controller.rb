class CommunityInvitationsController < ApplicationController

  respond_to :html

  load_and_authorize_resource :only => [:accept,:decline]
  authorize_resource :only => :create

  def create
    email_pattern = /^[-a-z0-9_\+\.]+\@([-a-z0-9]+\.)+[a-z]{2,4}$/i
    if !(params[:community_invitation][:invitee_display_name].empty?) && email_pattern.match(params[:community_invitation][:invitee_display_name])
      email = params[:community_invitation][:invitee_display_name]
      if User.where(:email => email).first.nil?
        u = User.new
        u.email = email
        u.confirmation_token = User.confirmation_token
        u.skip_confirmation!
        u.save(:validate => false)
        params[:community_invitation][:invitee_user_id] = u.id
      else
        params[:community_invitation][:invitee_display_name] = User.where(:email => email).first.display_name
      end
    end
    @community_invitation = CommunityInvitation.new(params[:community_invitation])
    @community_invitation.inviter = current_user
    @community_invitation.community_id = params[:id]
    if @community_invitation.save
      unless params[:community_invitation][:invitee_user_id].nil?
        u = User.find(params[:community_invitation][:invitee_user_id])
        if u.display_name.nil?
          InviteMailer.community_invite(u, @current_user, Community.find(params[:id])).deliver
        end
      end
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
