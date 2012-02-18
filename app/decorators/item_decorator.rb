class ItemDecorator < ApplicationDecorator
  decorates :item

  def tagged_as
    if item.tags.any?
      h.content_tag :li, "Tagged as: #{item.tags.collect(&:name).sort.join(', ')}"
    end
  end
end