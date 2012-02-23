class ItemDecorator < ApplicationDecorator
  decorates :item
  include Draper::LazyHelpers

  def bottom_of_form(f)
    if item.persisted?
      render :partial => 'items/bottom_of_edit_form', :locals => { :f => f, :item => self }
    else
      render :partial => 'items/bottom_of_new_form', :locals => { :f => f }
    end
  end

  def expires_on_string
    if item.expires_on.present?
      content_tag :div, "Currently Expires on: #{item.expires_on.strftime('%m/%d/%Y')}"
    else
      content_tag :div, "Not Currently set to Expire"
    end
  end

  def linkified_tags
    item.tags.collect{|tag| link_to( tag.name, {:controller => 'feeds', :action => :all, :tag_name => tag.name }) }.join(', ')
  end

  def manage_links
    if h.can? :manage, item
      edit_link = link_to('Edit', send("edit_#{item.class.to_s.underscore}_path",item))
      delete_link = link_to('Delete', item, :confirm => 'Are you sure?', :method => :delete)
      toggle_active_text = item.active ? 'Deactivate' : 'Activate'
      toggle_active_link = link_to( toggle_active_text, send("toggle_active_#{item.class.to_s.underscore}_path",item))
      content_tag :li, "#{edit_link} #{delete_link} #{toggle_active_link}".html_safe
    end
  end

  def tagged_as
    if item.tags.any?
      content_tag :li, "Tagged as: #{linkified_tags}".html_safe
    end
  end

  def tag_list
    item.tags.collect(&:name).sort.join(', ')
  end

end