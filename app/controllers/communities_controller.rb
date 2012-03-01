class CommunitiesController < ApplicationController
  respond_to :html
  authorize_resource

  def show
    @community = CommunityDecorator.find(params[:id])
  end

  def new
    @community = CommunityDecorator.decorate Community.new
  end

  def create
    @community = Community.new(params[:community])
    @community.user = current_user
    @community.save
    respond_with @community
  end
end
