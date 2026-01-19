class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true
  has_many :refunds, dependent: :restrict_with_error
  
  enum status: {
    pending: 'pending',
    authorized: 'authorized', 
    captured: 'captured',
    failed: 'failed',
    cancelled: 'cancelled',
    partially_refunded: 'partially_refunded',
    refunded: 'refunded'
  }
  
  validates :fincode_order_id, presence: true, uniqueness: true
  validates :fincode_access_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  
  after_update :update_product_stock, if: -> { 
    saved_change_to_status? && captured? && order.present?
  }
  
  def can_capture?
    authorized? && !captured? && !failed? && !cancelled?
  end

  def can_cancel?
    authorized? && !captured? && !failed? && !cancelled?
  end
  
  def can_refund?
    captured? || partially_refunded?
  end
  
  def refundable_amount
    return 0 unless can_refund?
    amount - refunds.completed.sum(:amount)
  end
  
  def total_refunded
    refunds.completed.sum(:amount)
  end
  
  def fully_refunded?
    can_refund? && refundable_amount <= 0
  end
  
  private
  
  def update_product_stock
    return unless order&.product
    
    if order.product.stock_quantity >= order.quantity
      order.product.decrement!(:stock_quantity, order.quantity)
    else
      errors.add(:base, 'Insufficient stock')
      raise ActiveRecord::RecordInvalid, self
    end
  end
end
