class DropUserSetDisplayNameFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :user_set_display_name
  end

  def down
    add_column :users, :user_set_display_name, :boolean, :default => true, :null => false
  end
end
