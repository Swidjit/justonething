class CreateListsUsers < ActiveRecord::Migration
  def change
    create_table :lists_users, :id => false do |t|
      t.references :user, :null => false
      t.references :list, :null => false
    end

    add_index :lists_users, [:list_id,:user_id], :unique => true
    add_index :lists_users, :user_id
  end
end
