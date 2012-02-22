class RenameStartAndEndTimeForItems < ActiveRecord::Migration
  def up
    rename_column :items, :start_time, :start_datetime
    rename_column :items, :end_time, :end_datetime
  end

  def down
    rename_column :items, :start_datetime, :start_time
    rename_column :items, :end_datetime, :end_time
  end
end
