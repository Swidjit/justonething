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
    content_tag :div, link_to(item.user.display_name, profile_path(item.user.display_name)), :class => 'smIcon3 smIcon'
  end

  def timing
    if item.start_datetime.present?
      content_tag :div, DateTimeDecorator.new(item.start_datetime).event_start_time, :class => 'cal_icon smIcon'
    end
  end

  def description
    h.auto_link(h.simple_format(linkified_description), :link => :urls)
  end

  def short_description
    linkify_tags(linkify_profiles(h.truncate_on_word(item.description, 400)))
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

  def iconic_information(with_type=true)
    icon_tags = []
    icon_tags << tagged_as
    icon_tags << geo_tagged_as
    icon_tags << creator
    icon_tags << timing
    icon_tags << price_tag
    icon_tags << location_tag
    icon_tags << condition_tag
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

  def manage_links
    links = []

    if h.can? :manage, item
      links << link_to('Edit', edit_polymorphic_path(item))
      links << link_to('Delete', item, :confirm => 'Are you sure?', :method => :delete)
      toggle_active_text = item.active ? 'Deactivate' : 'Activate'
      links << link_to(toggle_active_text, send("toggle_active_#{item.class.to_s.underscore}_path",item))
    end

    if h.current_user.present?
      #check for bookmarks
      if h.current_user.bookmarks.map(&:item).include?(item)
        bookmark = h.current_user.bookmarks.detect { |bookmark| bookmark.item == item }
        links << link_to('Remove Bookmark', bookmark_path(bookmark), :method => :delete)
      else
        links << link_to('Bookmark', bookmarks_path(:item_id => item.id), :method => :post)
      end
    end

    if h.current_user
      #check for rsvps
      if h.current_user.rsvps.map(&:item).include?(item)
        rsvp = Rsvp.find_by_user_id_and_item_id(h.current_user.id, item.id)
        links << link_to('Cancel RSVP', rsvp_path(rsvp), :method => :delete)
      elsif item.type == 'Event'
        links << link_to('RSVP', rsvps_path(:item_id => item.id), :method => :post)
      end
    end

    if h.can? :create, Comment
      links << link_to('Comment', send("#{item.class.to_s.underscore}_path",item,:anchor => 'comment'))
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

    if icons.any?
      h.content_tag(:ul, icons.join(' ').html_safe, :class => 'menu_with_dropdowns')
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

  def geo_tagged_as
    if item.geo_tags.any?
      content_tag :div, linkified_geo_tags.html_safe, :class => 'smIcon1 smIcon'
    end
  end

  def tag_list
    item.tags.collect(&:name).sort.join(', ')
  end

  def thumb
    if item.thumbnail.present?
      ImageDecorator.new(item.thumbnail).thumb
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
    polymorphic_url(item)
  end

  def remove_visibility_rule_path
    send("remove_visibility_rule_#{item.class.to_s.underscore}_path",item)
  end

end
