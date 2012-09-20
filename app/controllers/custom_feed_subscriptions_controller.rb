class CustomFeedSubscriptionsController < ApplicationController

  def index
     @user_subscriptions  = current_user.custom_feed_subscriptions;
     #render 'index'      
  end
    
  def create
    @feed_subscription = CustomFeedSubscription.new
    @feed_subscription.frequency = params[:feed_subscription][:frequency]
    @feed_subscription.custom_feed_id = params[:feed_subscription][:feed_id]
    @feed_subscription.user = current_user
    if @feed_subscription.save
      puts("saved")
    else
      puts("failed")
    end                       
  end
  
  def update_frequency
    @feed_subscription = CustomFeedSubscription.find(params[:feed_subscription][:id])
    @feed_subscription.frequency = params[:feed_subscription][:frequency]
    if @feed_subscription.save
      puts("saved")
    else
      puts("failed")
    end
  end

  def destroy
    @feed_subscription = CustomFeedSubscription.find(params[:feed_subscription][:id])
    @feed_description.destroy
  end
  
end
