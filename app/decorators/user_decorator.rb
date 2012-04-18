class UserDecorator < ApplicationDecorator
  decorates :user

  def add_to_list
    if h.current_user.lists.any?
      h.render :partial => 'add_to_list', :locals => {:user => model}
    end
  end

  def manage_links(link_wrapper)
    html = []

    if h.current_user != user && h.current_user.persisted?
      delegation = h.current_user.delegation_for_user(user)

      if delegation.blank?
        html << h.link_to('add as delegate', h.delegates_path(:delegatee_id => user.id), :method => :post)
      else
        html << h.link_to('remove as delegate', h.delegate_path(delegation), :method => :delete)
      end

      if !user.vouches.collect(&:voucher_id).include? h.current_user.id
        html << h.link_to('vouch for', h.user_vouches_path(:user_id => user.id), :method => :post)
      end
    end

    if h.can? :manage, user
      html << h.link_to('Edit Profile', h.edit_user_path(user))
    end

    if link_wrapper.present?
      html.map!{|link| h.content_tag(link_wrapper,link)}
    end

    return html.join(' ').html_safe
  end

  def item_creation_links
    links = []
    if h.params[:controller] != 'communities' || user.community_ids.include?(h.params[:id].to_i)
      path_options = {:format => :js}
      path_options.merge!({:community_id => h.params[:id] }) if h.params[:controller] == 'communities'
      links << h.link_to('have-it', h.new_have_it_path(path_options), :id => 'post_have_it', :class => 'add_item_txt item_first')
      links << h.link_to('want-it', h.new_want_it_path(path_options), :id => 'post_want_it', :class => 'add_item_txt')
      links << h.link_to('thoughts', h.new_thought_path(path_options), :id => 'post_thought', :class => 'add_item_txt')
      links << h.link_to('link', h.new_link_path(path_options), :id => 'post_link', :class => 'add_item_txt')
      links << h.link_to('event', h.new_event_path(path_options), :id => 'post_event', :class => 'add_item_txt')
      links << h.link_to('collection', h.new_collection_path(path_options), :id => 'post_collection', :class => 'add_item_txt')
    end
    links.join(' ').html_safe
  end

  def vouches_display
    vouch_count = user.vouches.count
    vouch_label = h.content_tag :div, h.pluralize(vouch_count, 'Vouch'), :class => 'label'
    h.content_tag :div, "#{h.image_tag('voucher.png', :height => '20px')} #{vouch_label}".html_safe,:class => 'voucher'
  end
end
