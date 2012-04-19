class GeoTagsController < ApplicationController
  respond_to :json

  def create
    current_user.add_geo_tag(params[:name])
    respond_to { |format| format.json { render :json => {} } }
  end

  def destroy
    current_user.rm_geo_tag(params[:id])
    respond_to { |format| format.json { render :json => {} } }
  end
end
