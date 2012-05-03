class CommentDecorator < ApplicationDecorator
  decorates :comment

  include SharedDecorations
  linkifies_all_in :text

  def text
    h.auto_link(h.simple_format(linkified_text), :link => :urls)
  end
end
