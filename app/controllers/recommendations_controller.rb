class RecommendationsController < ApplicationController

  def create
    @recommendation = Recommendation.new(params["recommendation"])
    @recommendation.item = Item.find(item_id_from_slug(params["id"]))
    @recommendation.user = current_user
    @recommendation.save
    respond_to do |f|
      f.html { redirect_to :back }
      f.json { render :json => {:success => @recommendation.valid?, :item => @recommendation.to_json} }
    end
  end

end
