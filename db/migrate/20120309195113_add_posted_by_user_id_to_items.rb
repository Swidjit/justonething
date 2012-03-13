class AddPostedByUserIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :posted_by_user_id, :integer
    add_foreign_key :items, :users, :column => :posted_by_user_id
  end
end
