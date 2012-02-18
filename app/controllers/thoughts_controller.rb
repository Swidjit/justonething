class ThoughtsController < ApplicationController
  respond_to :html

  def show
    @thought = ThoughtDecorator.find(params[:id])
  end

  def new
    @thought = Thought.new
  end

  def create
    @thought = Thought.create(params[:thought])
    respond_with @thought
  end
end