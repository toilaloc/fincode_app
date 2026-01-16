class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_one :payment, dependent: :destroy
  
  validates :number, presence: true, uniqueness: true
  validates :total_amount, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  
  before_validation :set_defaults, on: :create
  before_create :generate_order_number
  
  def paid?
    payment&.captured?
  end
  
  private
  
  def set_defaults
    self.quantity ||= 1
    self.total_amount = product.price * quantity if product
  end
  
  def generate_order_number
    self.number = "ORD#{Time.current.strftime('%Y%m%d')}#{SecureRandom.hex(4).upcase}"
  end
end
