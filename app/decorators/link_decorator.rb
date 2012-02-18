class LinkDecorator < ItemDecorator
  decorates :link

  def link_tag
    goto = link.link
    if goto.index(/[\w]+:\/\//).nil?
      goto = "http://#{goto}"
    end
    h.link_to link.link, goto, {:target => '_blank'}
  end
end