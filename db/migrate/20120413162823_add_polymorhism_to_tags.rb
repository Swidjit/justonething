class AddPolymorhismToTags < ActiveRecord::Migration
  def change
    add_column :tags, :type, :string

    remove_index :tags, :name
    add_index :tags, [:name, :type]
  end
end
