class CreateOpenHours < ActiveRecord::Migration
  def change
    create_table :open_hours do |t|
      t.string :day_of_week
      t.string :open_time
      t.string :close_time
      t.references :user, :null => false

      t.timestamps
    end
  end
end
