class AddPostIdToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :post_id, :integer
  end
end
