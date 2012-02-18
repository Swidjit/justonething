class CreateEvents < ActiveRecord::Migration
  def change
    add_column :items, :location, :string
    add_column :items, :start_time, :datetime
    add_column :items, :end_time, :datetime
  end
end
