class AddUserIdToOfferMessages < ActiveRecord::Migration
  def change
    add_column :offer_messages, :user_id, :integer, :null => false
    add_foreign_key :offer_messages, :users
  end
end
