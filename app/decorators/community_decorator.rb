class CommunityDecorator < ApplicationDecorator
  decorates :community

  def invitation_form
    if (community.users.include?(h.current_user) && community.is_public) || community.user_id == h.current_user.id
      h.content_tag :li, h.render( :partial => 'community_invitations/form', :locals => { :community => self } )
    end
  end

  def manage_links(container = 'li')
    links = []
    has_invite = h.current_user.rec_comm_invites.pending.collect(&:community_id).include? community.id
    if !community.users.include?(h.current_user) && (community.is_public || has_invite)
      links << h.link_to("Join", h.join_community_path(community), {:method => :post})
    elsif community.user != h.current_user && community.users.include?(h.current_user)
      links << h.link_to("Leave", h.leave_community_path(community), {:method => :delete, :confirm => 'Are you sure?'})
    end
    if links.any?
      h.content_tag container.to_sym, links.join(' ').html_safe
    end
  end

end