class Region < ActiveRecord::Base
  validates :name, presence: true, length: {maximum: 50}
  validates :description, presence: true, length: {maximum: 50}
  validates :boundaries, presence: true, length: {maximum: 200}
end
