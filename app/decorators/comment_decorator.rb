class CommentDecorator < ApplicationDecorator
  decorates :comment

  include SharedDecorations
  linkifies_all_in :text

  def text
    h.simple_format(linkified_text)
  end
end
