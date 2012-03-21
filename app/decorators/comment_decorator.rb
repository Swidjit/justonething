class CommentDecorator < ApplicationDecorator
  decorates :comment

  include SharedDecorations
  linkifies_all_in :text

  def text
    linkified_text
  end
end
