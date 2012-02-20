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

  def expires_on
    if item.expires_on.present?
      content_tag :div, "Currently Expires on: #{item.expires_on.strftime('%m/%d/%Y')}"
    end
  end

  def manage_links
    if h.can? :manage, item
      edit_link = link_to('Edit', send("edit_#{item.class.to_s.underscore}_path",item))
      delete_link = link_to('Delete', item, :confirm => 'Are you sure?', :method => :delete)
      content_tag :li, "#{edit_link} #{delete_link}".html_safe
    end
  end

  def tagged_as
    if item.tags.any?
      content_tag :li, "Tagged as: #{tag_list}"
    end
  end

  def tag_list
    item.tags.collect(&:name).sort.join(', ')
  end

end