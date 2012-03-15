class RecommendationsController < ApplicationController

  def create
    @recommendation = Recommendation.new(params["recommendation"])
    @recommendation.item = Item.find(params["id"])
    @recommendation.user = current_user
    @recommendation.save
    respond_to do |f|
      f.json { render :json => {:success => @recommendation.valid?, :item => @recommendation.to_json} }
    end
  end

end
