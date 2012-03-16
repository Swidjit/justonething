class AddCounterCacheForRecommendationsToItems < ActiveRecord::Migration
  def change
    add_column :items, :recommendations_count, :integer, :null => false, :default => 0

    execute('UPDATE items SET recommendations_count = (SELECT COUNT(*) FROM recommendations WHERE item_id = items.id);')
  end
end
