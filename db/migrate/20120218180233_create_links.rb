class CreateLinks < ActiveRecord::Migration
  def change
    add_column :items, :link, :string
  end
end
