class Recommendation < ActiveRecord::Base
  validates :userid, presence: true, numericality: { only_integer: true }
  validates :post_date, presence: true
  validates :doctor_name, presence: true, length: { maximum: 100 }
end
