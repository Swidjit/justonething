class CreateOffersAndOfferMessages < ActiveRecord::Migration
  def up
    create_table :offers do |t|
      t.integer :item_id
      t.integer :user_id

      t.timestamps
    end
    add_foreign_key :offers, :items
    add_foreign_key :offers, :users

    create_table :offer_messages do |t|
      t.integer :offer_id
      t.string :text

      t.timestamps
    end
    add_foreign_key :offer_messages, :offers
  end

  def down
    drop_table :offer_messages
    drop_table :offers
  end
end
