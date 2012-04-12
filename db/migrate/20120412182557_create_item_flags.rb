class CreateItemFlags < ActiveRecord::Migration
  def up
    create_table :item_flags do |t|
      t.integer :user_id
      t.integer :item_id

      t.timestamps
    end

    add_foreign_key :item_flags, :users
    add_foreign_key :item_flags, :items
  end

  def down
  end
end
