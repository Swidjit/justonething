class AddBusinessUserTypes < ActiveRecord::Migration
  def up
    add_column :users, :is_business, :boolean
    add_column :users, :business_name, :string
  end

  def down
    remove_column :users, :is_business
    remove_column :users, :business_name
  end
end
