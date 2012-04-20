class CreateCitiesUsers < ActiveRecord::Migration
  def change
    create_table :cities_users do |t|
      t.integer :city_id
      t.integer :user_id
    end
    add_index :cities_users, [:city_id, :user_id], :unique => true
    add_foreign_key :cities_users, :cities, :dependent => :delete
    add_foreign_key :cities_users, :users, :dependent => :delete
  end
end
