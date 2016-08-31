class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.integer :userid
      t.datetime :post_date
      t.string :doctor_name

      t.timestamps null: false
    end
  end
end
