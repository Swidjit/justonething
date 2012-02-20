class HaveItsController < ApplicationController
  respond_to :html
  authorize_resource :only => [:destroy, :edit, :update]
  before_filter :load_decorated_resource, :only => [:show,:edit,:update]

  def show
  end

  def new
    @have_it = HaveItDecorator.new HaveIt.new
  end

  def create
    @have_it = HaveIt.new(params[:have_it])
    @have_it.user ||= current_user
    @have_it.save
    respond_with @have_it
  end

  def edit
  end

  def update
    @have_it.update_attributes(params[:have_it])
    respond_with @have_it
  end

  def destroy
    @have_it = HaveIt.find(params[:id])
    @have_it.destroy
    flash[:notice] = "Have It successfully deleted."
    if request.referer == have_it_url(params[:id])
      redirect_to root_path
    else
      redirect_to :back
    end
  end

  private
  def load_decorated_resource
    @have_it = HaveItDecorator.find(params[:id])
  end
end