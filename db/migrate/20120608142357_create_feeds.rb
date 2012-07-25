class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.references :user
      t.string :name
      t.string :url
      t.datetime :last_read_at

      t.timestamps
    end
    add_foreign_key :feeds, :users, dependent: :delete
  end
end
