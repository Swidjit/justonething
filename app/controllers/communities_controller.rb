class CommunitiesController < ApplicationController
  respond_to :html
  authorize_resource
  before_filter :load_deocarted_resource, :only => [:show,:join]

  def show
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

  def join
    current_user.communities << @community
    if current_user.save
      flash[:notice] = "Successfully joined Community"
    else
      flash[:notice] = "Failed to join Community"
    end
    redirect_to community_path(@community)
  end

private
  def load_deocarted_resource
    @community = CommunityDecorator.find(params[:id])
  end
end
