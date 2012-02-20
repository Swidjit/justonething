class HaveItsController < ApplicationController
  respond_to :html
  authorize_resource :only => :destroy

  def show
    @have_it = HaveItDecorator.find(params[:id])
  end

  def new
    @have_it = HaveIt.new
  end

  def create
    @have_it = HaveIt.new(params[:have_it])
    @have_it.user ||= current_user
    @have_it.save
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
end