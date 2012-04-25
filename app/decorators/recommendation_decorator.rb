class RecommendationDecorator < ApplicationDecorator
  decorates :recommendation

  include SharedDecorations
  linkifies_all_in :description

  def description
    h.simple_format(linkified_description)
  end
end
