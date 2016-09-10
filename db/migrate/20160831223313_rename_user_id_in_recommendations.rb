class RenameUserIdInRecommendations < ActiveRecord::Migration
  def change
    rename_column :recommendations, :userid, :user_id
  end
end
