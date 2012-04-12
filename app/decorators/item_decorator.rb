class ItemDecorator < ApplicationDecorator
  decorates :item
  include Draper::LazyHelpers

  include SharedDecorations
  linkifies_all_in :description, :title

  def add_visibility_rule_options
    user = item.user || h.current_user

    option_hash = {}
    option_hash['communities'] = user.communities.collect{|c| {:name => c.name, :type => "community", :vis_id => c.id} }
    option_hash['lists'] = user.lists.collect{|c| {:name => c.name, :type => "list", :vis_id => c.id} }
    option_hash
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
    linkified_description
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
    icon_tags << creator
    icon_tags << timing
    icon_tags << price_tag
    if with_type
      icon_tags << content_tag(:span, "#{image_tag('have_icon.jpg')} #{item.class.to_s.humanize}".html_safe)
    end
    icon_tags.join("").html_safe
  end

  def linkified_tags
    item.tags.collect{|tag| link_to( tag.name, {:controller => 'feeds', :action => :all, :tag_name => tag.name }) }.join(', ')
  end

  def manage_links
    links = []

    if h.current_user.present?
      if h.current_user.bookmarks.map(&:item).include?(item)
        bookmark = h.current_user.bookmarks.detect { |bookmark| bookmark.item == item }
        links << link_to('', bookmark_path(bookmark), :method => :delete, :title => 'Remove Bookmark', :class => 'iconLink1 iconFirst')
      else
        links << link_to('', bookmarks_path(:item_id => item.id), :method => :post, :title => 'Bookmark', :class => 'iconLink1 iconFirst')
      end
    end

    if h.can? :create, Comment
      links << link_to('', send("#{item.class.to_s.underscore}_path",item,:anchor => 'comment'), :title => 'Comment', :class=> 'iconLink2')
    end

    if h.current_user.present? && !item.flagged_by_user?(current_user)
      links << link_to('', send("flag_#{item.class.to_s.underscore}_path", item), :class => 'iconLink3', :title => 'Flag', :method => :put)
    end

    if h.can? :manage, item
      links << link_to('', send("edit_#{item.class.to_s.underscore}_path",item), :title => 'Edit', :class => 'iconLink4')
      links << link_to('Delete', item, :confirm => 'Are you sure?', :method => :delete)
      toggle_active_text = item.active ? 'Deactivate' : 'Activate'
      links << link_to( toggle_active_text, send("toggle_active_#{item.class.to_s.underscore}_path",item))
    end
    if h.can? :create, Item
      links << link_to('', send("duplicate_#{item.class.to_s.underscore}_path",item), :title=> 'Duplicate', :class => 'iconLink5')
    end
    if h.can? :recommend, item
      links << h.render(:partial => 'recommendations/form', :locals => { :item => self })
    end

    links << facebook_like_button
    links.join(' ').html_safe
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

  def tag_list
    item.tags.collect(&:name).sort.join(', ')
  end

  def title
    linkified_title
  end

  def tokenized_visibility_rules
    tokenized_rules = []
    item.item_visibility_rules.each do |rule|
      this_obj = rule.visibility
      token_class = "#{rule.visibility_type.downcase}_token"
      tokenized_rules << h.content_tag(:div, (''.html_safe + this_obj.name + ' ' +
        link_to('x','#',:class => 'visibility_rule_remove',
          'data-rule-type' => rule.visibility_type.downcase,
          'data-visibility-id' => rule.visibility_id)),
        :class => token_class)
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
    send("#{item.class.to_s.underscore}_url",item)
  end

  def remove_visibility_rule_path
    send("remove_visibility_rule_#{item.class.to_s.underscore}_path",item)
  end

end
