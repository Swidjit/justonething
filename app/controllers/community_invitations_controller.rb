class CommunityInvitationsController < ApplicationController

  respond_to :html

  load_and_authorize_resource :only => [:accept,:decline]
  authorize_resource :only => :create

  def create
    email_pattern = /^[-a-z0-9_\+\.]+\@([-a-z0-9]+\.)+[a-z]{2,4}$/i
    community = Community.find(params[:id])
    unless community.nil?
      unless params[:invitees].empty?
        invitees = params[:invitees].split(',')
        invitees.each do |i|
          if email_pattern.match(i.strip)
            email = i.strip
            u = User.where(:email => email).first
            if u.nil?
              u = User.new
              u.email = email
              u.confirmation_token = User.confirmation_token
              u.skip_confirmation!
              u.save(:validate => false)
              if generate_invitation(u, community)
                InviteMailer.community_invite(u, current_user, community).deliver
              end
            else
              generate_invitation(u, community)
            end
          else
            u = User.by_lower_display_name(i.strip)
            unless u.nil?
              generate_invitation(u, community)
            end
          end
        end
      end
      redirect_to community_path(params[:id])
    else
      redirect_to '/'
    end
  end

 # def create
 #   email_pattern = /^[-a-z0-9_\+\.]+\@([-a-z0-9]+\.)+[a-z]{2,4}$/i
 #   if !(params[:community_invitation][:invitee_display_name].empty?) && email_pattern.match(params[:community_invitation][:invitee_display_name])
 #     email = params[:community_invitation][:invitee_display_name]
 #     if User.where(:email => email).first.nil?
 #       u = User.new
 #       u.email = email
 #       u.confirmation_token = User.confirmation_token
 #       u.skip_confirmation!
 #       u.save(:validate => false)
 #       params[:community_invitation][:invitee_user_id] = u.id
 #     else
 #       params[:community_invitation][:invitee_display_name] = User.where(:email => email).first.display_name
 #     end
 #   end
 #   @community_invitation = CommunityInvitation.new(params[:community_invitation])
 #   @community_invitation.inviter = current_user
 #   @community_invitation.community_id = params[:id]
 #   if @community_invitation.save
 #     unless params[:community_invitation][:invitee_user_id].nil?
 #       u = User.find(params[:community_invitation][:invitee_user_id])
 #       if u.display_name.nil?
 #         InviteMailer.community_invite(u, @current_user, Community.find(params[:id])).deliver
 #       end
 #     end
 #     flash[:notice] = 'Invitation successfully sent'
 #   else
 #     flash[:notice] = "Invitation failed to send" #{@community_invitation.errors.full_messages}"
 #   end
 #   redirect_to community_path(params[:id])
 # end

  def accept
    @community_invitation.accept!
    redirect_to community_path(@community_invitation.community)
  end

  def decline
    @community_invitation.decline!
    redirect_to community_path(@community_invitation.community)
  end

  private

  def generate_invitation(user, community)
    @community_invitation = community.community_invitations.build({
      'inviter_id' => current_user.id,
      'invitee_id' => user.id})
    @community_invitation.save
  end

end
