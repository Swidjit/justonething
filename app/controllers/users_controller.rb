class UsersController < ApplicationController
  respond_to :html
  authorize_resource :only => :show
  before_filter :load_resource, :only => :show

  def show
  end

  private
  def load_resource
    @user = User.find(params[:id])
  end
end
