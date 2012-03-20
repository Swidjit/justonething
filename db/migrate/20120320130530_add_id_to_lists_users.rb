class AddIdToListsUsers < ActiveRecord::Migration
  def change
    add_column :lists_users, :id, :primary_key

  end
end
