class VouchesController < ApplicationController

  def create
    vouch = Vouch.new
    vouch.voucher_id = current_user.id
    vouch.vouchee_id = params[:id]
    if vouch.save
      flash[:notice] = 'Successfully vouched for user'
    else
      flash[:notice] = 'Failed to vouch for user'
    end
    if vouch.vouchee.present?
      redirect_to profile_path(vouch.vouchee.display_name)
    else
      redirect_to root
    end
  end

end
