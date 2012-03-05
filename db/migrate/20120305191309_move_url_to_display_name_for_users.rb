class MoveUrlToDisplayNameForUsers < ActiveRecord::Migration
  def up
    rename_column :users, :user_set_url, :user_set_display_name
    remove_index :users, :url
    remove_column :users, :url

    add_index :users, :display_name
  end

  def down
    add_column :users, :url, :string
    add_index :users, :url
    rename_column :users, :user_set_display_name, :user_set_url

    remove_index :users, :display_name
  end
end
