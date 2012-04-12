class AddDisbaleFlagToItems < ActiveRecord::Migration
  def change
    add_column :items, :disabled, :boolean, :default => false
  end
end
