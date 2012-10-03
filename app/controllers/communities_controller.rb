class CommunitiesController < ApplicationController
  respond_to :html
  authorize_resource
  before_filter :load_deocarted_resource, :except => :index

  def index
    @communities = CommunityDecorator.decorate Community.accessible_by(current_ability)
  end

  def show
    @upcoming_events = Calendar.upcoming_events(community: @community, user: @user, city: current_city, ability: current_ability).map {|e| EventDecorator.decorate e }
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = @community.items.where(:type => item_type.camelize.singularize).access_controlled_for(current_user, current_city, current_ability)
    else
      params[:type] = 'all'
      @feed_items = @community.items.access_controlled_for(current_user, current_city, current_ability)
    end
    render_paginated_feed :show
  end

  def new
  end
  
  def edit
    @community = Community.find(params[:id])
  end
  
  def destroy
    if(Community.find(params[:id])).destroy
      flash[:notice] = "Successfully deleted community"
      redirect_to root_path
    else
      redirect_to root_path
      flash[:notice] = "Error deleting community"
    end
  end

  def create
    @community.assign_attributes(params[:community])
    @community.user = current_user
    @community.save
    respond_with @community
  end
  
  def update
    @community.assign_attributes(params[:community])
    @community.user = current_user
    @community.save
    respond_with @community
  end

  def join
    invites = CommunityInvitation.find_all_by_community_id_and_invitee_id_and_status(@community.id,current_user.id,'P')
    if @community.is_public || invites.any?
      CommunityInvitation.update_all({:status => 'A'}, {:id => invites.collect(&:id)})
      current_user.communities << @community
      if current_user.save
        flash[:notice] = "Successfully joined Community"
      else
        flash[:notice] = "Failed to join Community"
      end
    else
      flash[:notice] = "This community requires an invitation to join"
    end
    #if request.referer.present?
    #  redirect_to :back
    #else
    redirect_to community_path(@community)
    #end
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
    if request.referer.present?
      redirect_to :back
    else
      redirect_to community_path(@community)
    end
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
