class Admin::UsersController < Admin::ApplicationController
  before_filter :load_users, :only => :index
  before_filter :load_user, :only => :destroy

  def index
  end

  def destroy
    if @user.destroy
      flash[:notice] = 'Successfully deleted user'
    else
      flash[:notice] = 'Failed to delete user'
    end
    redirect_to users_path
  end

private

  def load_users
    @users = User.order(:zipcode, :last_name, :first_name).all
  end

  def load_user
    @user = User.find(params[:id])
  end
end
