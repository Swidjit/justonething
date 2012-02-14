class WantItsController < ApplicationController
  respond_to :html

  def show
    @want_it = WantIt.find(params[:id])
  end

  def new
    @want_it = WantIt.new
  end

  def create
    @want_it = WantIt.create(params[:want_it])
    respond_with @want_it
  end
end