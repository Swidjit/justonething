class WantItsController < ApplicationController
  respond_to :html
  authorize_resource :only => [:destroy,:edit,:update]
  before_filter :load_decorated_resource, :only => [:show,:edit,:update]

  def show
  end

  def new
    @want_it = WantItDecorator.new WantIt.new
  end

  def create
    @want_it = WantIt.new(params[:want_it])
    @want_it.user ||= current_user
    @want_it.save
    respond_with @want_it
  end

  def edit
  end

  def update
    @want_it.update_attributes(params[:want_it])
    respond_with @want_it
  end

  def destroy
    @want_it = WantIt.find(params[:id])
    @want_it.destroy
    flash[:notice] = "Want It successfully deleted."
    if request.referer == want_it_url(params[:id])
      redirect_to root_path
    else
      redirect_to :back
    end
  end

  private
  def load_decorated_resource
    @want_it = WantItDecorator.find(params[:id])
  end
end