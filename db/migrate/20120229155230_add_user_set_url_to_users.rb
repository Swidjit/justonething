class AddUserSetUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_set_url, :boolean, :default => false, :null => false

  end
end
