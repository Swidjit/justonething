class HaveItsController < ApplicationController
  respond_to :html

  def show
    @have_it = HaveItDecorator.find(params[:id])
  end

  def new
    @have_it = HaveIt.new
  end

  def create
    @have_it = HaveIt.create(params[:have_it])
    respond_with @have_it
  end
end