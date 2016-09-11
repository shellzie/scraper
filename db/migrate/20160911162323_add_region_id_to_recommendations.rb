class AddRegionIdToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :region_id, :integer
  end
end
