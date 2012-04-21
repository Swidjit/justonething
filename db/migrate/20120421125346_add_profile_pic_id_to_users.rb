class AddProfilePicIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_pic_id, :integer

  end
end
