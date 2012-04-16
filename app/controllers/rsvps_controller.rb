class RsvpsController < ApplicationController
  load_and_authorize_resource :only => :destroy

  def index
    @rsvps = Rsvp.for_user(current_user).all
  end

  def create
    if params[:item_id].present?
      rsvp = Rsvp.new(:item_id => params[:item_id], :user => current_user)

      if rsvp.save
        flash[:notice] = "RSVP saved."
      else
        flash[:error] = "An error occurred."
      end
    end

    redirect_to :back
  end

  def destroy
    if @rsvp.destroy
      flash[:notice] = "RSVP removed"
    else
      flash[:error] = "An error occurred."
    end

    redirect_to :back
  end
end