class UserDecorator < ApplicationDecorator
  decorates :user

  def add_to_list
    if h.current_user.lists.any?
      html = h.content_tag :div, h.select("user_id", "", h.current_user.lists.collect {|p| [ p.name, p.id ] },
          {:include_blank => 'add to list'}, {:id => 'add_user_to_list_dropdown' })
      html += h.hidden_field_tag 'user_id_for_list', user.id, :id => 'user_id_for_list'
      html += h.content_tag :div, '', :id => 'add_user_to_list_message'
    end
  end

  def manage_links
    html = []

    if h.current_user != user
      delegation = h.current_user.delegation_for_user(user)

      if delegation.blank?
        html << h.link_to('add as delegate', h.delegates_path(:delegatee_id => user.id), :method => :post)
      else
        html << h.link_to('remove as delegate', h.delegate_path(delegation), :method => :delete)
      end
    end

    if h.can? :manage, user
      html << h.link_to('Edit Profile', h.edit_user_path(user))
    end

    return html.join(' ').html_safe
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
