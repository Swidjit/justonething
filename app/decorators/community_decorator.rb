class CommunityDecorator < ApplicationDecorator
  decorates :community

  def description
    h.simple_format(community.description)
  end

  def invitation_form
    if h.current_user.present?
      if (community.users.include?(h.current_user) && community.is_public) || community.user_id == h.current_user.id
        h.content_tag :div, h.render( :partial => 'community_invitations/form', :locals => { :community => self } )
      end
    end
  end

  def manage_links(container = 'li')
    links = []
    if h.current_user.present?
      has_invite = h.current_user.rec_comm_invites.pending.collect(&:community_id).include? community.id
      if !community.users.include?(h.current_user) && (community.is_public || has_invite)
        links << h.link_to("Join", h.join_community_path(community), {:method => :post})
      elsif community.user != h.current_user && community.users.include?(h.current_user)
        links << h.link_to("Leave", h.leave_community_path(community), {:method => :delete, :confirm => 'Are you sure?'})
      end
      if h.can? :delete, community
        links << h.link_to("Delete this community", h.community_path(community), {:method => :delete})
      end
      if h.can? :manage, community
        links << h.link_to("Edit community", {:action => "edit",:id => community.id})
      end
    end
    if links.any?
      #h.content_tag container.to_sym, links.join(' ').html_safe
      h.render(:partial => 'communities/manage_menu', :locals => {:links => links})
    end
  end

end