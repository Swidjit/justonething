class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :file_uid  # For storing path to Dragonfly image.
      t.string :file_name # For appending original filenames to Dragonfly URIs.

      t.timestamps
    end
  end
end