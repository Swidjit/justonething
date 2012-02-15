class DropDisplayNameUniqueForUsers < ActiveRecord::Migration
  def up
    remove_index :users, :display_name
  end

  def down
    add_index :users, :display_name, :uniq => true
  end
end
