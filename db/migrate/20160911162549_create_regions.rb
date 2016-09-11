class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.text  :description
      t.text :boundaries
    end
  end
end
