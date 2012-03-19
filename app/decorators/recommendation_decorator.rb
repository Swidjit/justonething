class RecommendationDecorator < ApplicationDecorator
  decorates :recommendation

  include SharedDecorations
  linkifies_all_in :description

  def description
    linkified_description
  end
end
