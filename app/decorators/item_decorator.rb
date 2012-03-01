require("#{Rails.root}/lib/shared_tag_decorations.rb")
class ItemDecorator < ApplicationDecorator
  decorates :item
  include Draper::LazyHelpers

  extend SharedTagDecorations
  linkifies_tags_in :description

  def bottom_of_form(f)
    if item.persisted?
      render :partial => 'items/bottom_of_edit_form', :locals => { :f => f, :item => self }
    else
      render :partial => 'items/bottom_of_new_form', :locals => { :f => f, :item => self }
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

  def distinct_url
    send("#{item.class.to_s.underscore}_url",item)
  end

end