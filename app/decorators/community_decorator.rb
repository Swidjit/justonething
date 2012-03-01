class CommunityDecorator < ApplicationDecorator
  decorates :community

  def manage_links
    links = []
    if !community.users.include? h.current_user
      links << h.link_to("Join", h.join_community_path(community), {:method => :post})
    elsif community.user != h.current_user
      links << h.link_to("Leave", h.leave_community_path(community), {:method => :delete, :confirm => 'Are you sure?'})
    end
    if links.any?
      h.content_tag :li, links.join(' ').html_safe
    end
  end

end