class CreateEventOccurrences < ActiveRecord::Migration
  def up
    add_column :items, :rules, :text
  end
  def down
    remove_column :items, :rules
  end
end
