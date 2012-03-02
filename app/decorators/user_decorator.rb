class UserDecorator < ApplicationDecorator
  decorates :user

  def manage_links
    if h.can? :manage, user
      h.link_to 'Edit Profile', h.edit_user_path(user)
    end
  end

  def item_creation_links
    links = []
    if h.params[:controller] != 'communities' || user.community_ids.include?(h.params[:id].to_i)
      path_options = {:community_id => h.params[:id] } if h.params[:controller] == 'communities'
      links << h.link_to('have-it', h.new_have_it_path(path_options), :id => 'post_have_it')
      links << h.link_to('want-it', h.new_want_it_path(path_options), :id => 'post_want_it')
      links << h.link_to('thoughts', h.new_thought_path(path_options), :id => 'post_thought')
      links << h.link_to('link', h.new_link_path(path_options), :id => 'post_link')
      links << h.link_to('event', h.new_event_path(path_options), :id => 'post_event')
    end
    links.join(' ').html_safe
  end
end