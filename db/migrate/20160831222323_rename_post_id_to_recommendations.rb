class RenamePostIdToRecommendations < ActiveRecord::Migration
  def change
    rename_column :recommendations, :post_id, :topic_id
  end
end
