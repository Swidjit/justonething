class ThoughtsController < ApplicationController
  respond_to :html
  authorize_resource :only => [:destroy, :edit, :update]
  before_filter :load_decorated_resource, :only => [:show,:edit,:update]

  def show
  end

  def new
    @thought = ThoughtDecorator.new Thought.new
  end

  def create
    @thought = Thought.new(params[:thought])
    @thought.user ||= current_user
    @thought.save
    respond_with @thought
  end

  def edit
  end

  def update
    @thought.update_attributes(params[:thought])
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

  private
  def load_decorated_resource
    @thought = ThoughtDecorator.find(params[:id])
  end
end