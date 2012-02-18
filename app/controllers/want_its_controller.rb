class WantItsController < ApplicationController
  respond_to :html

  def show
    @want_it = WantItDecorator.find(params[:id])
  end

  def new
    @want_it = WantIt.new
  end

  def create
    @want_it = WantIt.new(params[:want_it])
    @want_it.user ||= current_user
    @want_it.save
    respond_with @want_it
  end
end