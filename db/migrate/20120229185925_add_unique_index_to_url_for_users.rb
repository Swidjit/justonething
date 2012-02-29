class AddUniqueIndexToUrlForUsers < ActiveRecord::Migration
  def change
    add_index :users, :url, :unique => true
  end
end
