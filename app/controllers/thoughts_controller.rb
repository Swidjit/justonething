class ThoughtsController < ApplicationController
  respond_to :html
  authorize_resource :only => :destroy

  def show
    @thought = ThoughtDecorator.find(params[:id])
  end

  def new
    @thought = Thought.new
  end

  def create
    @thought = Thought.new(params[:thought])
    @thought.user ||= current_user
    @thought.save
    respond_with @thought
  end

  def destroy
    @thought = Thought.find(params[:id])
    @thought.destroy
    flash[:notice] = "Thought successfully deleted."
    if request.referer == thought_url(params[:id])
      redirect_to root_path
    else
      redirect_to :back
    end
  end
end