class RemindersController < ApplicationController
  load_and_authorize_resource :only => :destroy

  def create
    if params[:item_id].present?
      reminder = Reminder.new(:item_id => params[:item_id], :user => current_user, :date => params[:date])

      if reminder.save
        flash[:notice] = "Reminder saved."
      else
        flash[:error] = "An error occurred."
      end
    end

    redirect_to :back
  end

  def destroy
    if @reminder.destroy
      flash[:notice] = "Reminder removed"
    else
      flash[:error] = "An error occurred."
    end

    redirect_to :back
  end
  
end