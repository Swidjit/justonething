class UserDecorator < ApplicationDecorator
  decorates :user

  def add_to_list
    if h.current_user.present? && h.current_user.lists.any?
      h.render :partial => 'add_to_list', :locals => {:user => model}
    end
  end

  def name
    user.is_business ? user.business_name : "#{user.first_name} #{user.last_name}"
  end

  def about
    h.simple_format(user.about)
  end

  def websites
    return if model.websites.blank?

    sites_arr = model.websites.split(' ')
    link_arr = sites_arr.reduce([]) { |memo, site| memo << h.link_to(site, site) }
    link_arr.join(' ').html_safe
  end

  def manage_links(link_wrapper)
    html = []
    icons = []

    if h.can? :manage, user
      html << h.link_to('Edit Profile', h.edit_user_path(user))
    end
    
    if h.current_user.present? && h.current_user != user && h.current_user.persisted?
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
        
   
    
    if html.any?
      html << h.render(:partial => 'items/manage_feed_item_menu', :locals => {:links => html})
    end  
     if h.current_user.present? && h.current_user.lists.any?
        /html << h.render(:partial => 'vouch', :locals => {:user => model})/
        html << h.render(:partial => 'add_to_list', :locals => {:user => model})
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
    else
      links << h.content_tag(:span, 'you must be a member of the community')
    end
    links.join(' ').html_safe
  end

  def linked_profile_pic(size='150')
    h.link_to( profile_pic(size), h.profile_path(self.display_name))
  end

  def profile_pic(size='150')
    pic_options = { :alt => self.display_name, :class => 'user_prof_pic' }
    puts "test"
    if user.profile_pic.present?
      ImageDecorator.new(user.profile_pic).thumb("#{size}x#{size}>",pic_options)
    else
      pic_options[:width] = size;
      pic_options[:height] = size;
      h.image_tag('default-profile-picture.png', pic_options)
    end
  end

  def vouches_display
    vouch_count = user.vouches.count
    vouch_label = h.content_tag :div, h.pluralize(vouch_count, 'Vouch'), :class => 'label'
    h.content_tag :div, vouch_label,:class => 'voucher'
  end
end
