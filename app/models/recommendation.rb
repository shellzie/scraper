class Recommendation < ActiveRecord::Base
  validates :user_id, presence: true, numericality: {only_integer: true}
  validates :doctor_name, presence: true, length: { maximum: 100 }
  validates :topic_id, presence: true, numericality: {only_integer: true}
  validates :created_at, presence: false
  validates :updated_at, presence: false
  validates :post_date, presence: true
end
