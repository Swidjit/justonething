class DelegatesControllerController < ApplicationController
  def create
    if params[:delegatee_id].present?
      delegation = Delegate.new
      delegation.delegator = current_user
      delegation.delegatee_id = params[:delegatee_id]

      if delegation.save
       flash[:notice] = "Successfully created delegate."
      else
        flash[:notice] = "Failed to create delegate."
      end
    end

    redirect_to :back
  end

  def destroy
    delegation = Delegate.find(params[:id])
    if delegation.present? && current_user == delegation.delegator
      delegation.destroy
      flash[:notice] = "Successfully removed delegate."
    else
      flash[:notice] = "Failed to remove delegate."
    end

    redirect_to :back
  end
end
