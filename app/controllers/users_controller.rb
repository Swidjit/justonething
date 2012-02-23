class UsersController < ApplicationController
  respond_to :html
  authorize_resource :only => :show
  before_filter :load_resource, :only => :show

  def show
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = @user.items.where(:type => item_type.camelize.singularize).active.accessible_by(current_ability)
    else
      @feed_items = @user.items.active.accessible_by(current_ability)
    end
  end

  private
  def load_resource
    @user = User.find(params[:id])
  end
end
