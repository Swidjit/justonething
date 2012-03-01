class CreateCommunities < ActiveRecord::Migration
  def change
    create_table :communities do |t|
      t.string :name, :null => false
      t.text :description
      t.references :user

      t.timestamps
    end
  end
end
