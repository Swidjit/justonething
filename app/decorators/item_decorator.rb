class ItemDecorator < ApplicationDecorator
  decorates :item
  include Draper::LazyHelpers

  include SharedDecorations
  linkifies_all_in :description, :title

  def add_visibility_rule_options
    user = item.user || h.current_user

    option_hash = {}
    option_hash['cities'] = user.cities.collect{|c| {:name => c.display_name, :type => 'city', :vis_id => c.id} }
    option_hash['communities'] = user.communities.collect{|c| {:name => c.name, :type => "community", :vis_id => c.id} }
    option_hash['lists'] = user.lists.collect{|c| {:name => c.name, :type => "list", :vis_id => c.id} }
    option_hash
  end

  def class_feed
    content_tag(:span, link_to("#{item.class.to_s.titleize}:", main_feeds_path(:type => item.class.to_s.pluralize.underscore)), :class => 'title_heading')
  end

  def condition_tag
    if item.condition.present?
      content_tag :div, item.condition, :class => 'smIcon6 smIcon'
    end
  end

  def creator
    if item.user.present?
      content_tag :div, link_to(item.user.display_name, profile_path(item.user.display_name)), :class => 'smIcon3 smIcon'
    end
  end

  def timing(include_icon = true)
    if item.start_datetime.present?
      icon_class = include_icon ? 'cal_icon smIcon' : ''
      # you already have the EventDecorator to format the time, so why send it to DateTimeDecorator?
      content_tag :div, next_occurrence, class: icon_class
      # content_tag :div, DateTimeDecorator.new(start_datetime).event_start_time, :class => icon_class
    end
  end

  def description
    h.auto_link(h.simple_format(linkified_description), :link => :urls)
  end

  def short_description
    h.auto_link(linkify_tags(linkify_profiles(h.truncate_on_word(item.description, 250))), :link => :urls)
  end

  def collections
    if model.collections.any?
      collection_arr = model.collections.reduce([]) { |memo, collection| memo << link_to(collection.title, collection_url(collection)) }
      content_tag :div, collection_arr.join(', ').html_safe, :class => 'collection_icon smIcon'
    end
  end

  def expires_on_string
    if item.expires_on.present?
      content_tag :div, "Currently Expires on: #{item.expires_on.strftime('%m/%d/%Y')}"
    else
      content_tag :div, "Not Currently set to Expire"
    end
  end

  def expires_on
    if item.expires_on.present?
      item.expires_on.strftime('%m/%d/%Y')
    end
  end

  def expires_on_fields(f)
    expires_on_input = f.input :expires_on, :as => :string_for_radio, :input_html => {:class => 'datepicker', :value => expires_on}
    f.input :has_expiration, :as => :radio, :label => 'Expires', :collection => { 'Never' => 0, "#{expires_on_input}".html_safe => 1 }
  end

  def facebook_like_button
    "<div class='fb-like' data-href='#{distinct_url}' data-send='false' data-layout='button_count' data-width='50' data-show-faces='false'></div>"
  end

  def info_icons
    info_icons = []
    info_icons << price_tag
    info_icons << location_tag
    info_icons << condition_tag
    info_icons.join("").html_safe
  end

  def iconic_information(with_type=true)
    icon_tags = []
    icon_tags << tagged_as
    icon_tags << geo_tagged_as
    icon_tags << creator
    icon_tags << timing
    icon_tags << price_tag
    icon_tags << location_tag
    icon_tags << condition_tag
    icon_tags << collections
    if with_type
      icon_tags << content_tag(:div, item.class.to_s.humanize, :class => 'smIcon smIcon4')
    end
    icon_tags << facebook_like_button
    icon_tags.join("").html_safe
  end

  def linkified_tags
    item.tags.collect{|tag| link_to( tag.name, h.main_feeds_path({:type => 'all', :tag_name => tag.name })) }.join(', ')
  end

  def linkified_geo_tags
    item.geo_tags.collect{|tag| link_to( tag.name, {:controller => 'feeds', :action => :geo, :tag_name => tag.name }) }.join(', ')
  end

  def location_tag
    if item.location.present?
      content_tag :div, item.location, :class => 'smIcon5 smIcon'
    end
  end

  def links_bar
    links = []
    links.join('').html_safe
  end

  def manage_links
    links = []
    if h.can? :manage, item
      links << link_to('edit', edit_polymorphic_path(item))
      if item.type == 'Event' and item.is_recurrence? and (h.params[:controller] == 'calendars' or h.params[:date])
        links << link_to('Delete One', event_path(item, date: item.start_datetime.to_s(:ymd)), confirm: 'Are you sure? This will only delete this instance of the event, and not the entire event.', method: :delete)
        links << link_to('Delete All', item, :confirm => 'Are you sure? This will delete all instances of the event.', :method => :delete)
      else
        links << link_to('Delete', item, :confirm => 'Are you sure?', :method => :delete)
      end
      active_text = item.active ? 'Deactivate' : 'Activate'
      links << link_to(active_text, send("toggle_active_#{item.class.to_s.underscore}_path",item))
    end

    if h.can? :create, Item
      links << link_to('Duplicate', send("duplicate_#{item.class.to_s.underscore}_path",item))
    end

    if h.current_user.present? && !item.flagged_by_user?(current_user)
      links << link_to('Flag', send("flag_#{item.class.to_s.underscore}_path", item), :method => :put)
    end

    ('<ul class="link-list"><li>'+links.join('</li><li>')+'</li></ul>').html_safe
  end

  def manage_links_old
    links = []

    if h.can? :manage, item
      links << link_to('Edit', edit_polymorphic_path(item))
      
      msg = 'Are you sure?'
      delete_text = 'Delete'
      if item.type == 'Event' and item.is_recurrence? and (h.params[:controller] == 'calendars' or h.params[:date])
        links << link_to('Delete One', event_path(item, date: item.start_datetime.to_s(:ymd)), confirm: 'Are you sure? This will only delete this instance of the event, and not the entire event.', method: :delete)
        msg << ' This will delete event and all of its instances.'
        delete_text << ' All'
      end
      links << link_to(delete_text, item, :confirm => msg, :method => :delete)
      toggle_active_text = item.active ? 'Deactivate' : 'Activate'
      links << link_to(toggle_active_text, send("toggle_active_#{item.class.to_s.underscore}_path",item))
    end

    if h.current_user.present?
      #check for bookmarks
      if item.bookmark_users.include?(h.current_user)
        bookmark = item.bookmarks.detect { |bookmark| bookmark.user_id == current_user.id }
        link = bookmark_path(bookmark)
        h.render(:partial => 'items/bookmark_button', :locals => {:link => link})
      else
        link = bookmarks_path(:item_id => item.id)
        h.render(:partial => 'items/bookmark_button', :locals => {:link => link})
      end
    end

    if h.current_user && item.type == 'Event'
      #check for rsvps
      if item.rsvp_users.include?(h.current_user)
        rsvp = item.rsvps.where(:user_id => h.current_user.id).first
        links << link_to('Cancel RSVP', rsvp_path(rsvp), :method => :delete)
      else
        links << link_to('RSVP', rsvps_path(:item_id => item.id), :method => :post)
      end
      
      # check for reminders
      if item.has_reminder_for?(current_user)
        reminder = item.reminder_for_user current_user
        links << link_to('Cancel Reminder', reminder_path(reminder), method: :delete)
      else
        remind_me_text = 'Remind Me'
        if item.is_recurring? or item.is_recurrence?
          links << link_to('Remind Me Once', reminders_path(item_id: item.id, date: item.start_datetime.to_s(:ymd)), method: :post)
          remind_me_text << ' Every Time'
        end
        links << link_to(remind_me_text, reminders_path(item_id: item.id), method: :post)
      end
      links << link_to('Export to Calendar', event_path(item, format: :ics))
      
    end

    if h.can? :create, Item
      links << link_to('Duplicate', send("duplicate_#{item.class.to_s.underscore}_path",item))
    end

    if h.current_user.present? && !item.flagged_by_user?(current_user)
      links << link_to('Flag', send("flag_#{item.class.to_s.underscore}_path", item), :method => :put)
    end

    icons = []

    if h.current_user && h.current_user.can_collect?(item)
      icons << h.render(:partial => 'items/add_to_collection', :locals => {:item => item})
    end

    if links.any?
      icons << h.render(:partial => 'items/manage_menu', :locals => {:links => links})
    end
    icons << h.render(:partial => 'items/social_bar')
    if icons.any?
      h.content_tag(:div, icons.join(' ').html_safe)
    else
     ''
    end
  end

  def manage_links_lite
    links = []

    if h.can? :manage, item
      links << link_to('Edit', edit_polymorphic_path(item))
      
      msg = 'Are you sure?'
      delete_text = 'Delete'
      links << link_to(delete_text, item, :confirm => msg, :method => :delete)
      toggle_active_text = item.active ? 'Deactivate' : 'Activate'
      links << link_to(toggle_active_text, send("toggle_active_#{item.class.to_s.underscore}_path",item))
    end

    if h.current_user.present?
      #check for bookmarks
      if item.bookmark_users.include?(h.current_user)
        bookmark = item.bookmarks.detect { |bookmark| bookmark.user_id == current_user.id }
        links << link_to('Remove Bookmark', bookmark_path(bookmark), :method => :delete)
      else
        links << link_to('Bookmark', bookmarks_path(:item_id => item.id), :method => :post)
      end
    end

    if h.can? :create, Item
      links << link_to('Duplicate', send("duplicate_#{item.class.to_s.underscore}_path",item))
    end

    if h.current_user.present? && !item.flagged_by_user?(current_user)
      links << link_to('Flag', send("flag_#{item.class.to_s.underscore}_path", item), :method => :put)
    end

    icons = []

    if links.any?
      icons << h.render(:partial => 'items/manage_feed_item_menu', :locals => {:links => links})
    end

    if icons.any?
      h.content_tag(:ul, icons.join(' ').html_safe)
    else
     ''
    end
  end


  def price_tag
    if item.cost.present?
      content_tag :div, item.cost, :class => 'smIcon2 smIcon'
    end
  end

  def tagged_as
    if item.tags.any?
      content_tag :div, linkified_tags.html_safe, :class => 'smIcon1 smIcon'
    end
  end
  
  def tag_List
    if item.tags.any?
      item.tags.each {|tag| tag_list = tag_list + tag.name}
    end
  end
  
  def clean_desc
    #- item.description.gsub(/<\/?[^>]*>/, "") 
    #- item.description.gsub("!&#x000A;", " ")
    item.description
  end 

  def geo_tagged_as
    if item.geo_tags.any?
      content_tag :div, linkified_geo_tags.html_safe, :class => 'smIcon1 smIcon'
    end
  end

  def tag_list_display
    item.tags.collect(&:name).sort.join(', ')
  end

  def thumb
    if item.thumbnail.present?
      ImageDecorator.new(item.thumbnail).thumb
    else
      h.image_tag("item-thumbnails/#{item.class.to_s.underscore.gsub('_', '-')}-thumbnail.png")
    end
  end

  def thumb_with_lightbox
    if item.thumbnail.present?
      link_to(thumb,ImageDecorator.new(item.thumbnail).full_size_url,{:rel => 'lightbox'})
    end
  end

  def title
    linkified_title
  end

  def short_title
    linkify_tags(linkify_profiles(h.truncate_on_word(item.title, 40)))
  end

  def tokenized_visibility_rules
    tokenized_rules = []
    item.item_visibility_rules.each do |rule|
      # if we do this as a Where in the line above, then it shoots off a new query
      # for unpersisted items and doesn't find the default rule added for the city
      if %w( Community List City ).include?(rule.visibility_type)
        this_obj = rule.visibility
        token_class = "#{rule.visibility_type.downcase}_token"
        tokenized_rules << h.content_tag(:div, (''.html_safe + this_obj.name + ' ' +
          link_to('x','#',:class => 'visibility_rule_remove',
            'data-rule-type' => rule.visibility_type.downcase,
            'data-visibility-id' => rule.visibility_id)),
          :class => token_class)
      end
    end
    tokenized_rules.join(' ').html_safe
  end

  def visibility_form
    if h.can? :manage, item
      render(:partial => 'visibility_form', :locals => { :ajax => true, :item => self })
    end
  end
  
  def suggest_item_form
    render(:partial => 'suggest_item_form', :locals => { :ajax => true, :item => self })

  end

  def offer_users_for_select
    h.options_from_collection_for_select(item.offers.map(&:user), :id, :display_name)
  end

###
# URL Methods
###

  def add_visibility_rule_path
    send("add_visibility_rule_#{item.class.to_s.underscore}_path",item)
  end

  def distinct_url
    h.polymorphic_url(item)
  end

  def remove_visibility_rule_path
    send("remove_visibility_rule_#{item.class.to_s.underscore}_path",item)
  end

end
