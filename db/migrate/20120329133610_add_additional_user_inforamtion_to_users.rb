class AddAdditionalUserInforamtionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :about, :text
    add_column :users, :websites, :string
    add_column :users, :address, :string
    add_column :users, :phone, :string
  end
end
