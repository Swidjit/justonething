class CommunitiesController < ApplicationController
  respond_to :html
  authorize_resource
  before_filter :load_deocarted_resource, :except => :index

  def index
    @communities = CommunityDecorator.decorate Community.accessible_by(current_ability)
  end

  def show
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = @community.items.where(:type => item_type.camelize.singularize).accessible_by(current_ability)
    else
      params[:type] = 'all'
      @feed_items = @community.items.accessible_by(current_ability)
    end
  end

  def new
  end

  def create
    @community.assign_attributes(params[:community])
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
    if params[:id].present?
      @community = CommunityDecorator.find(params[:id])
    else
      @community = CommunityDecorator.decorate Community.new
    end
  end
end
