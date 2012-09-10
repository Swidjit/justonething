class CreateCustomFeedSubscriptions < ActiveRecord::Migration
  def up
    create_table :custom_feed_subscriptions do |t|
      t.references :user, :null => false
      t.references :custom_feed, :null => false
      t.integer :frequency, :null => false, :default => 9999
    end

    add_index :custom_feed_subscriptions, [:custom_feed_id,:user_id], :unique => true
    add_index :custom_feed_subscriptions, :user_id
  end
  def down
    drop_table :custom_feed_subscriptions
  end 
   
end
