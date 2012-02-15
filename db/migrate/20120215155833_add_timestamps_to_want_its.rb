class AddTimestampsToWantIts < ActiveRecord::Migration
  def change
    change_table :want_its do |t|
      t.timestamps
    end
  end
end
