class PagesController < ApplicationController
  def index
    @title = params[:page_name].titleize
    render params[:page_name]
  end

  def home
    @recent_have_its = HaveIt.order_by_created_at.limit(20).all.sample(4)
    @recent_want_its = WantIt.order_by_created_at.limit(20).all.sample(4)
    @upcoming_events = Calendar.upcoming_events city: current_city, ability: current_ability
    @recent_thoughts = Thought.order_by_created_at.limit(20).all.sample(4)
    @recent_collections = Collection.order_by_created_at.limit(20).all.sample(4)
    @recent_links = Link.order_by_created_at.limit(20).all.sample(4)
  end
end
