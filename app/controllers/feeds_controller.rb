class FeedsController < ApplicationController

  def tag
    @tag = Tag.find_by_name(params[:tag_name])
    @feed_items = @tag.present? ? @tag.items.accessible_by(current_ability) : []
    @feed_title = "Tag: #{params[:tag_name]}"
    render :index
  end

  # Per discussion between Isaiah and Sonny: single action for each item type
  # Eventually List action
  # Index action with query string that combines all types of filtering

end
