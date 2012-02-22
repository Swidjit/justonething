class AddActiveFlagToItems < ActiveRecord::Migration
  def change
    add_column :items, :active, :boolean, :null => false, :default => true

  end
end
