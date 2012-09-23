class UserPagesController < ApplicationController
  respond_to :html
  before_filter :load_resource

  def show
    @user_page = UserPage.find(params[:id])
    @user = @user_page.user
  end

  def new
    @user_page = UserPage.new
  end
  
  def edit
    @user_page = UserPage.find(params[:id])
  end
  
  def destroy
    if(UserPage.find(params[:id])).destroy
      flash[:notice] = "Successfully deleted Page"
      redirect_to root_path
    else
      redirect_to root_path
      flash[:notice] = "Error deleting Page"
    end
  end

  def create    
    @user_page = UserPage.new
    @user_page.assign_attributes(params[:user_page])
    @user_page.user = current_user
    @user_page.save
    respond_with @user_page
  end
  
  def update
    @user_page = UserPage.find(params[:id])
    @user_page.assign_attributes(params[:user_page])
    @user_page.user = current_user
    @user_page.save
    respond_with @user_page
  end
private
  def load_resource
    if params[:id].present?
      @community = Community.find(params[:id])
    end
  end  
  
end
