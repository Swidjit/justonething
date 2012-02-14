class CreateWantIts < ActiveRecord::Migration
  def change
    create_table :want_its do |t|
      t.string :title, :null => false
      t.text :description
      t.date :expires_on
      t.references :user
    end
  end
end
