class LinksController < ApplicationController
  respond_to :html

  def show
    @link = LinkDecorator.find(params[:id])
  end

  def new
    @link = Link.new
  end

  def create
    @link = Link.create(params[:link])
    respond_with @link
  end
end