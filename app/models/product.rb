class Product < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :orders
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  
  scope :active, -> { where(active: true) }
  
  def in_stock?
    true
  end
end
