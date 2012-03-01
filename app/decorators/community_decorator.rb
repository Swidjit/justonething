class CommunityDecorator < ApplicationDecorator
  decorates :community

  def manage_links
    links = []
    if !community.users.include? h.current_user
      links << h.link_to("Join", h.join_community_path(community), {:method => :post})
    end
    if links.any?
      h.content_tag :li, links.join(' ').html_safe
    end
  end

end