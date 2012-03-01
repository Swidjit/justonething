class CommunitiesController < ApplicationController
  respond_to :html
  authorize_resource
  before_filter :load_deocarted_resource, :only => [:show,:join,:leave]

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

  def leave
    Rails.logger.debug current_user.inspect
    if @community.users.include?(current_user) && current_user != @community.user
      @community.users.delete(current_user)
      if @community.save
        flash[:notice] = "Successfully left Community"
      else
        flash[:notice] = "Failed to leave Community"
      end
    end
    redirect_to community_path(@community)
  end

private
  def load_deocarted_resource
    @community = CommunityDecorator.find(params[:id])
  end
end
