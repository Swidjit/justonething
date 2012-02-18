class HaveItsController < ApplicationController
  respond_to :html

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
end