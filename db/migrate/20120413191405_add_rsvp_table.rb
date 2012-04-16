class AddRsvpTable < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.integer :user_id
      t.integer :item_id

      t.timestamps
    end

    add_foreign_key :rsvps, :users
    add_foreign_key :rsvps, :items
  end
end