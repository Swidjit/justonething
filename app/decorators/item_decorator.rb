class ItemDecorator < ApplicationDecorator
  decorates :item

  def manage_links
    if h.can? :manage, item
      h.content_tag :li, h.link_to('Delete', item, :confirm => 'Are you sure?', :method => :delete)
    end
  end

  def tagged_as
    if item.tags.any?
      h.content_tag :li, "Tagged as: #{item.tags.collect(&:name).sort.join(', ')}"
    end
  end

end