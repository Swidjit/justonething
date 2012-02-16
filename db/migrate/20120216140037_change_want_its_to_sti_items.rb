class ChangeWantItsToStiItems < ActiveRecord::Migration
  def change
    rename_table :want_its, :items
    add_column :items, :type, :string
  end
end
