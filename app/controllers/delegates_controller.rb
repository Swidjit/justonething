class DelegatesController < ApplicationController
  def create
    delegation = Delegate.new
    delegation.delegator = current_user
    if params[:user_display_name].present?
      delegatee = User.find_by_display_name(params[:user_display_name])
      delegation.delegatee = delegatee
    elsif params[:delegatee_id].present?
      delegation.delegatee_id = params[:delegatee_id]
    end

    if delegation.save
      flash[:notice] = "Successfully created delegate."
      success_val = true
      token_html = render_to_string('delegates/_delegate', :formats => [:html], :layout => false, :locals => { :delegate => DelegateDecorator.decorate(delegation) })
    else
      flash[:notice] = "Failed to create delegate."
      success_val = false
      token_html = ''
    end

    respond_to do |f|
      f.html { redirect_to :back }
      f.json { render :json => { :notice => flash[:notice], :success => success_val, :token_html => token_html} }
    end
  end

  def destroy
    delegation = Delegate.find(params[:id])
    if delegation.present? && current_user == delegation.delegator
      delegation.destroy
      flash[:notice] = "Successfully removed delegate."
      success_val = true
    else
      flash[:notice] = "Failed to remove delegate."
      success_val = false
    end

    respond_to do |f|
      f.html { redirect_to :back }
      f.json { render :json => { :notice => flash[:notice], :success => success_val} }
    end
  end
end
