class AddIsMentionToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :is_mention, :boolean, :null => false, :default => false

  end
end
