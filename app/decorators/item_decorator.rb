class ItemDecorator < ApplicationDecorator
  decorates :item
  include Draper::LazyHelpers

  include SharedDecorations
  linkifies_all_in :description, :title

  def add_visibility_rule_dropdown
    option_hash = {}
    option_hash[:communities] = h.current_user.communities.collect{|c| [c.name,"community-#{c.id}"] }
    option_hash[:lists] = h.current_user.lists.collect{|c| [c.name,"list-#{c.id}"] }
    h.select('add_visibility_rule','',grouped_options_for_select(option_hash),{:include_blank => 'add viewers'},{:id => 'add_visibility_rule'})
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

  def linkified_tags
    item.tags.collect{|tag| link_to( tag.name, {:controller => 'feeds', :action => :all, :tag_name => tag.name }) }.join(', ')
  end

  def manage_links
    links = []
    if h.can? :manage, item
      links << link_to('Edit', send("edit_#{item.class.to_s.underscore}_path",item))
      links << link_to('Delete', item, :confirm => 'Are you sure?', :method => :delete)
      toggle_active_text = item.active ? 'Deactivate' : 'Activate'
      links << link_to( toggle_active_text, send("toggle_active_#{item.class.to_s.underscore}_path",item))
    end
    links << link_to('Duplicate', send("duplicate_#{item.class.to_s.underscore}_path",item))
    links << facebook_like_button
    content_tag :li, links.join(' ').html_safe
  end

  def tagged_as
    if item.tags.any?
      content_tag :li, "Tagged as: #{linkified_tags}".html_safe
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
      tokenized_rules << h.content_tag(:div, (''.html_safe + this_obj.name + ' ' + link_to('x','#',:class => 'visibility_rule_remove',
          'data-rule-type' => rule.visibility_type.downcase, 'data-visibility-id' => rule.visibility_id)))
    end
    tokenized_rules.join(' ').html_safe
  end

  def visibility_form
    if h.can? :manage, item
      h.content_tag(:li, render(:partial => 'visibility_form', :locals => { :ajax => true, :item => self }))
    end
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