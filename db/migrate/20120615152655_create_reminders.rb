class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.references :item
      t.references :user
      t.date :date
      t.date :sent_on

      t.timestamps
    end
    add_foreign_key :reminders, :items, :name => "reminders_item_id_fk"
    add_foreign_key :reminders, :users, :name => "reminders_user_id_fk"

  end
end
